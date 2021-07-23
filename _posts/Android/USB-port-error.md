title: "UFP was modified as DRP when we unplug OTG"
date: 2019-08-27 22:11:32
categories:
- Android Tree
- Kernel
tags: [Qualcomm,USB,Bug]
---

# Term 
* DFP - Downstream Facing Port     
下行端口，可以理解为 Host 的 Type-c 端口或者作为 Host 的 hub ，DFP 提供 VBUS，可以提供数据。在协议规范中 DFP 特指数据的下行传输，笼统意义上指的是数据下行和对外提供电源的设备。典型的 DFP 设备是电源适配器。

* UFP - Upstream Facing port     
上行端口，可以理解为 Device 上的 Type-c 端口或者连接到 Host/DFP of a hub ，UFP 从 VBUS 中取电，并可提供数据。典型设备是 U 盘，移动硬盘。

* DRP - DUal Role Port (DFP + UFP)  
双角色端口，DRP 既可以做 DFP(Host)，也可以做 UFP(Device)，也可以在 DFP 与 UFP 间动态切换。典型的DRP设备是笔记本电脑。

> 引用摘录：A DRP port is a port that can operate as either a sink or source.
> 
> source - takes the data role of a DFP.
> sink - take the data role of a UFP.
> 
> A current sink is a port or circuit point that accepts negative current, e.g. current into the circuit which it drains to ground. 
> A current source is a port or circuit point that provides positive current. A good example of a current source is a DC power supply

# Description

逻辑：USB 默认为 UFP，不能使用 OTG ；若要使用需要通过 node 将其设为 DRP ， 但是在拔出后需要将其设回 UFP。 

问题： 当拔掉 OTG 之后，USB 仍然为 DRP ，导致不用设置 node 即可连接 OTG。

# Solution
<!--more-->

## 初步解析
通过在 smblib_handle_typec_removal 函数设置 USB 端口模式的地方加日志读取端口状态，发现 DRP 是被成功设置了的，但是短暂时间后又被其他地方修改为 UFP 模式了。

通过寄存器相关关键字等各种方式皆不能找到其余修改的地方。

因为老版本（Android N）上是没有问题的，所以尝试在本问题版本（Android Q） one by one 烧写 N 的镜像，最终发现 pmic.elf 分区会让问题得以解决。

## 方案一
对比代码发现如下两种修改方法可以解决问题：
```c
--------------------------------------------------------------
diff --git a/QcomPkg/Library/PmicLib/target/sdm660_pm660_pm660l/psi/pm_config_target_pbs_ram.c b/QcomPkg/Library/PmicLib/target/sdm660_pm660_pm660l/psi/pm_config_target_pbs_ram.c
index bfb32ba..cb012b4 100755
--- a/QcomPkg/Library/PmicLib/target/sdm660_pm660_pm660l/psi/pm_config_target_pbs_ram.c
+++ b/QcomPkg/Library/PmicLib/target/sdm660_pm660_pm660l/psi/pm_config_target_pbs_ram.c
@@ -58,7 +58,7 @@ pm_pbs_seq [ ][PBS_RAM_DATA_SIZE] =
      { 0x00,  0x1B,   0x01,   0x18},  // W#1 -        0x804 Header offset, Header Version, PBS RAM Revision, PBS RAM Branch
      { 0x2C,  0x08,   0xFF,   0x83},  // W#2 -        0x808 Start of trigger jump table:
      { 0x68,  0x08,   0xFF,   0x83},  // W#3 -        0x80C
# mothod first.
-      { 0xC4,  0x08,   0xFF,   0x83},  // W#4 -        0x810
+      { 0xB8,  0x08,   0xFF,   0x83},  // W#4 -        0x810
OR 
# mothod second.
-      { 0x38,  0x09,   0xFF,   0x83},  // W#5 -        0x814
+      { 0x2C,  0x09,   0xFF,   0x83},  // W#5 -        0x814
      { 0xC4,  0x0F,   0xFF,   0x83},  // W#6 -        0x818 Fixed Offset = RAM-Base-Addr + 0x18 + 0x00 => SLEEP-SET
      { 0xCC,  0x0F,   0xFF,   0x83},  // W#7 -        0x81C Fixed Offset = RAM-Base-Addr + 0x18 + 0x04 => PON X Reasons
--------------------------------------------------------------
```
但是针对这个问题咨询高通得到的回复是：PSI 模块是不允许修改的，会导致难以预料的问题，所以这种方案作罢。因为没有找到相关资料，不清楚这个差异具体是什么，高通也未给出清晰的答案。

## 方案二 
拔掉时延时 5 毫秒才重置 USB 为 UFP 模式，试图在 PSI 之后修改，经过测试此修改方案能解决此问题。如下：
```c
diff --git a/drivers/power/supply/qcom/smb-lib.c b/drivers/power/supply/qcom/smb-lib.c
--- a/drivers/power/supply/qcom/smb-lib.c
+++ b/drivers/power/supply/qcom/smb-lib.c
@@ -4378,12 +4378,28 @@
 #ifdef FEATURE__DET_DRIVER
 	/* configure power role for default */
 	_power_role_val.intval = _det_get_default_power_role();

+	msleep(5);  # 延时等 PSI 修改 USB 为 DRP 完成，然后我们再修改为 UFP
	rc = smblib_set_prop_typec_power_role(chg, &_power_role_val);
```


## 方案三
此方案与方案二类似，
```c
diff --git a/drivers/power/supply/qcom/smb-lib.c b/drivers/power/supply/qcom/smb-lib.c
--- a/drivers/power/supply/qcom/smb-lib.c
+++ b/drivers/power/supply/qcom/smb-lib.c
@@ -4378,12 +4378,28 @@
 #ifdef FEATURE__DET_DRIVER
 	/* configure power role for default */
 	_power_role_val.intval = _det_get_default_power_role();  // 获取需要设定端口模式
-	rc = smblib_set_prop_typec_power_role(chg, &_power_role_val);
-	if (rc < 0) {
-		smblib_err(chg,
-			"Couldn't configure power role for %d rc=%d\n", _power_role_val.intval, rc);
+	if(_power_role_val.intval == POWER_SUPPLY_TYPEC_PR_SINK){
+		rc = smblib_masked_write(chg, TYPE_C_INTRPT_ENB_SOFTWARE_CTRL_REG, TYPEC_DISABLE_CMD_BIT, TYPEC_DISABLE_CMD_BIT);
+		if(rc < 0)
+			smblib_err(chg, "Couldn't disable type-c\n");
+
+		msleep(200);  # 延时等 PSI 修改 USB 为 DRP 完成，然后我们再修改为 UFP
+		rc = smblib_masked_write(chg, TYPE_C_INTRPT_ENB_SOFTWARE_CTRL_REG, UFP_EN_CMD_BIT | DFP_EN_CMD_BIT, UFP_EN_CMD_BIT);
+		if(rc < 0)
+			smblib_err(chg, "Couldn't configure power role for %d rc=%d\n", _power_role_val.intval, rc);
+
+		msleep(10);
+		rc = smblib_masked_write(chg, TYPE_C_INTRPT_ENB_SOFTWARE_CTRL_REG, TYPEC_DISABLE_CMD_BIT, 0);
+		if(rc < 0)
+			smblib_err(chg, "Couldn't enable type-c\n");
+	}else{
+		rc = smblib_set_prop_typec_power_role(chg, &_power_role_val); // write 3 bit， if 中的内容部分算此函数的子集，只是提取出来添加了 TYPEC_DISABLE_CMD_BIT 和延时
+		if(rc < 0)
+			smblib_err(chg, "Couldn't configure power role for %d rc=%d\n", _power_role_val.intval, rc);
 	}
 #else
 	/* enable DRP */
 	rc = smblib_masked_write(chg, TYPE_C_INTRPT_ENB_SOFTWARE_CTRL_REG,

```
