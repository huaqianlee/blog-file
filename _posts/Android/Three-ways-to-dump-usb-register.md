title: "Three ways to dump usb register"
date: 2018-08-23 22:07:48
categories: Android
tags: [Qualcomm]
---
### Add node
此方法只为一个示例，有些平台不是使用此文件，如 SDM450（MSM8953）使用的 dwc3-qcom.c 。
```
# kernel/msm-4.9/drivers/usb/phy/phy-msm-usb.c
@@ -51,6 +51,11 @@
 
 #include <linux/msm-bus.h>
 
+#undef dev_dbg
+#define dev_dbg dev_info
+#undef pr_debug
+#define pr_debug pr_info
+
 /**
  * Requested USB votes for BUS bandwidth
  *
@@ -3601,6 +3606,53 @@ static int msm_otg_setup_devices(struct
 	return retval;
 }
 
+
+#define DUMP_ENTRIES	152
+
+static ssize_t usbphy_regs_show(struct device *dev,
+			       struct device_attribute *attr, char *buf)
+{
+	struct msm_otg *motg = the_msm_otg;
+	//struct msm_otg_platform_data *pdata = motg->pdata;
+	struct usb_phy *phy = &motg->phy;
+	u32 *dump;
+	unsigned int i,  n = 0;
+	//dbg_trace("[%s] %pK\n", __func__, buf);
+	if (attr == NULL || buf == NULL) {
+		dev_err(dev, "[%s] EINVAL\n", __func__);
+		return 0;
+	}
+	if (atomic_read(&motg->in_lpm)){
+	        dev_err(dev, "[%s] usb in lpm\n", __func__);
+		return 0;
+        }
+	dump = kmalloc(sizeof(u8) * DUMP_ENTRIES, GFP_KERNEL);
+	if (!dump)
+		return 0;
+
+        for(i = 0; i < DUMP_ENTRIES -1; i++)
+        dump[i] = ulpi_read(phy, i);
+
+	for (i = 0; i < DUMP_ENTRIES -1; i++) {
+		n += scnprintf(buf + n, PAGE_SIZE - n,
+			       "reg[0x%04X] = 0x%04X\n",
+			       i, dump[i]);
+	}
+	kfree(dump);
+
+	return n;
+}
+
+static ssize_t usbphy_regs_store(struct device *dev,
+		struct device_attribute *attr, const char
+		*buf, size_t size)
+{
+	return size;
+}
+
+static DEVICE_ATTR(usbphy_regs, 0644,
+		usbphy_regs_show, usbphy_regs_store);
+
 static ssize_t dpdm_pulldown_enable_show(struct device *dev,
 			       struct device_attribute *attr, char *buf)
 {
@@ -4426,6 +4478,7 @@ static int msm_otg_probe(struct platform
 	motg->caps |= ALLOW_HOST_PHY_RETENTION;
 
 	device_create_file(&pdev->dev, &dev_attr_dpdm_pulldown_enable);
+	device_create_file(&pdev->dev, &dev_attr_usbphy_regs);
 
 	if (motg->pdata->enable_lpm_on_dev_suspend)
 		motg->caps |= ALLOW_LPM_ON_DEV_SUSPEND;
@@ -4527,6 +4580,7 @@ otg_remove_devices:
 remove_cdev:
 	pm_runtime_disable(&pdev->dev);
 	device_remove_file(&pdev->dev, &dev_attr_dpdm_pulldown_enable);
+	device_remove_file(&pdev->dev, &dev_attr_usbphy_regs);
 	msm_otg_debugfs_cleanup();
 phy_reg_deinit:
 	devm_regulator_unregister(motg->phy.dev, motg->dpdm_rdev);
@@ -4619,6 +4673,7 @@ static int msm_otg_remove(struct platfor
 	usb_remove_phy(phy);
 
 	device_remove_file(&pdev->dev, &dev_attr_dpdm_pulldown_enable);
+	device_remove_file(&pdev->dev, &dev_attr_usbphy_regs);
 
 	/*
 	 * Put PHY in low power mode.
```

<!--more-->

### trace
通过如下指令去 crash 设备，然后用 trace32 去读取寄存器值。
```
echo c > /proc/sysrq-triger
```
### busybox
dump usb registers via busybox.
```
/data/busybox devmem <address> 32
or 
r <address>  # system/core/toolbox/r.c , 比 busybox 轻量化的一个工具
```