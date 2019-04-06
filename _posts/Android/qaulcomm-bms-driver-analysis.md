title: "高通电池管理系统（BMS）驱动分析"
date: 2015-06-24 21:52:24
categories: Android
tags: [源码分析,Qualcomm]
---
>File: qpnp-vm-bms.c -  Battery monitor system　
 

## 简要
BMS(Battery Monitoring System)主要提供如下功能：

- 通过一定算法计算SOC(state of charge电量状态) or 剩余电量.
    
- 正在使用的电池电压, 开漏电压(OCV).


![temp](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/qcom/bms_1.png)

## 硬件架构

<!--more-->
![hw_arch](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/qcom/bms_2.jpg)
硬件实现过冷过热检测停止充电：
![temp_monitor](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/qcom/bms_3.png)

<!--more-->        
## 工作状态机
![bms_state](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/qcom/bms_4.jpg)
## 软件架构
![sw_arch](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/qcom/bms_5.jpg)

SoC计算主要分为两部分:
```bash
# Kernel space
Hardware configuration
Initial SoC calculation
Shutdown OCV save
Battery detection
Set battery profile
Interrupts handling
Data read from the hardware data (FIFO and accumulator)
SoC lookup based on OCV (calculated in user space) and batt_temp
Driver source code is available at /drivers/power/qpnp-vm-bms.c

# User space
OCV calculation using hardware data (FIFO and accumulator) read from kernel space
Updates the calculated OCV to kernel space through power supply class
User space algorithm is shipped as a binary to the customers


# BMS driver is mainly composed of two main areas:
Interface
    Purpose – To update/report when there is a change in SoC
     Important functions
         get_prop_bms_capacity()
         get_prop_bms_rbatt()
         get_batt_therm()
         report_voltage_based_soc()
         report_vm_bms_soc()
         report_eoc()
Core engine
    Purpose – Calculate and save the state of the battery
    Important functions
         qpnp_vm_bms_probe()
         parse_bms_dt_properties()
         config_battery_data()
         battery_status_check()
         calculate_initial_soc
         bms_request_irqs()
         monitor_soc_work()
         report_state_of_charge()
```

## 驱动架构分析
### Interface Mapping
![IM](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/qcom/bms_6.jpg)
![IM](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/qcom/bms_7.jpg)
### 几个主要的结构体
```bash
/*This is the client/device handle returned when a SPMI device  is registered with a controller. */
struct spmi_device {
	struct device		dev;                       // 设备结构体,在内核中用来描述每一个结构体
	const char		*name;                  // 此设备在驱动中的名字
	struct spmi_controller	*ctrl;      // 管理挂接此spmi设备的SMPI控制者
	struct spmi_resource	res;                // SMPI resource for 主节点
	struct spmi_resource	*dev_node; // array of SPMI resources when used with spmi-dev-container
	u32			num_dev_node;         // 设备节点的数量
	u8			sid;                               // 从设备ID
};

/* struct spmi_controller: interface to the SPMI master controller */
struct spmi_controller {
	struct device		dev;
	unsigned int		nr;                                                                         //  board-specific number identifier for this controller/bus
	struct completion	dev_released;                                            // 完成状态
	int		(*cmd)(struct spmi_controller *, u8 opcode, u8 sid);// sends a non-data command sequence on the SPMI bus.
	int		(*read_cmd)(struct spmi_controller *,                          // sends a register read command sequence on the SPMI bus.
				u8 opcode, u8 sid, u16 addr, u8 bc, u8 *buf);
	int		(*write_cmd)(struct spmi_controller *,                         // sends a register write command sequence on the SPMI bus.
				u8 opcode, u8 sid, u16 addr, u8 bc, u8 *buf);
};

struct qpnp_bms_chip {
	struct device			*dev;
	struct spmi_device		*spmi;
	dev_t				dev_no;
	u16				base;
	u8				revision[2];
	u32				batt_pres_addr;
	u32				chg_pres_addr;

	/* status variables */
	u8				current_fsm_state;
	bool				last_soc_invalid;
        ....
}

struct device_node {
	const char *name;
	const char *type;
	phandle phandle;
	const char *full_name;
        ...
}

struct power_supply {
	const char *name;
	enum power_supply_type type;
	enum power_supply_property *properties;
	...
        int (*get_property)(...)  
        int (*set_property)(...)
        ...
       /* private */
      struct device *dev;
      ...
}
```
## 驱动分析
### 主线一: initialization - probe
![probe](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/qcom/bms_8.jpg)
```bash 
入口函数: static int qpnp_vm_bms_probe(struct spmi_device *spmi)    // 注册SMPI设备
          chip = devm_kzalloc(&spmi->dev, sizeof(*chip), GFP_KERNEL);   //给struct qpnp_bms_chip *chip(bms芯片设备)分配空间    
          rc = bms_get_adc(chip, spmi); // 获取adc设备       
                      chip->vadc_dev = qpnp_get_vadc(&spmi->dev, "bms")// 获取vadc设备 spmi --> spmi_device 
                      chip->iadc_dev = qpnp_get_iadc(&spmi->dev, "bms")  // 获取iadc设备      
                      chip->adc_tm_dev = qpnp_get_adc_tm(&spmi->dev, "bms")  // 获取temp adc设备
          revid_dev_node = of_parse_phandle(spmi->dev.of_node,"qcom,pmic-revid", 0);//获取struct device_node *revid_dev_node，解析dtsi配置文件(RREVID_REVID_PM8916寄存器（chip variant))。
          chip->revid_data = get_revid_data(revid_dev_node)   //
                       list_for_each_entry(revid_chip, &revid_chips, link) // 遍历链表获取revid_data
          rc = qpnp_pon_is_warm_reset(); //Checks if the PMIC went through a warm reset.
          chip->warm_reset = !!rc;  // converts not 0 to 1, 0  to 0
          rc = parse_spmi_dt_properties(chip, spmi)  // 解析spmi的dtsi配置文件
          rc = parse_bms_dt_properties(chip)    // 解析bms的dtsi配置文件
          if (chip->dt.cfg_disable_bms) 
                rc = qpnp_masked_write_base(chip, chip->base + EN_CTL_REG,BMS_EN_BIT, 0);  // disable VMBMS
          rc = qpnp_read_wrapper(chip, chip->revision,chip->base + REVISION1_REG, 2);//read version register
          dev_set_drvdata(&spmi->dev, chip)  // 给spmi设备驱动赋值
  device_init_wakeup(&spmi->dev, 1) // device wakeup initialization
  mutex_init(&chip->bms_xxx) // 初始化一个 chip->bms_xxx mutex_t
  init_waitqueue_head(&chip->bms_wait_q) // 初始化等待序列头    
          rc = set_battery_data(chip); 	//read battery-id and select the battery profile                        
              rc = config_battery_data(chip->batt_data) // set the battery profile 
              wakeup_source_init(&chip->vbms_xxx_source.source, name) // 根据name  prepare 一个wakeup source(chip->vbms_xxx_source.source)并添加入链表
              INIT_DELAYED_WORK(&chip->monitor_soc_work, monitor_soc_work); // 注册电量监控函数并延时                             
          INIT_DELAYED_WORK(&chip->voltage_soc_timeout_work,voltage_soc_timeout_work);
 bms_init_defaults(chip);  // chip 初始化为默认值
 bms_load_hw_defaults(chip); // load 写入设置chip硬件默认值
     setup_vbat_monitoring(chip); //vbat monitoring setup
                    qpnp_adc_tm_channel_measure(chip->adc_tm_dev,&chip->vbat_monitor_params)
     bms_request_irqs(chip)  // chip 请求中断
 battery_insertion_check(chip);// 电池插入检测
 battery_status_check(chip); // 电池状态检测:charging start/stop/full, 并执行相应操作
                charging_began(chip) // 开始充电
                charging_ended(chip) // 停止充电
     register_bms_char_device(chip) //character device to pass data to the userspace
alloc_chrdev_region(&chip->dev_no, 0, 1, "vm_bms")  // 为此设备分配空间
cdev_init(&chip->bms_cdev, &bms_fops) // 初始化此设备
cdev_add(&chip->bms_cdev, chip->dev_no, 1) // 加入设备链表
                chip->bms_class = class_create(THIS_MODULE, "vm_bms")  // create a class structure (class.c), be used in calls to device_create();
                chip->bms_device = device_create(chip->bms_class,NULL, chip->dev_no,NULL, "vm_bms");//creates a device and registers it with sysfs
    calculate_initial_soc(chip) // calculate and initial the SOC （select  soc form cutoff soc and current soc）
                 read_and_update_ocv(chip, batt_temp, true)
                 ...
                 rc = read_shutdown_ocv_soc(chip); // 读取上次关机电量
       xx = lookup_soc_ocv(chip, est_ocv,batt_temp); // 读取电量给相关变量赋值
       if（chip->warm_reset） //重启
          ...
       if(!shutdown_soc_invalid &&(abs(chip->shutdown_soc - chip->calculated_soc) <chip->dt.cfg_shutdown_soc_valid_limit)  //如果关机SOC和现在的soc相差小于
cfg_shutdown_soc_valid_limit  （msm-pm8916.dtsi 中定义：qcom,shutdown-soc-valid-limit = <5>;）
         ...
)
   /* setup & register the battery power supply */
   ....  chip->bms_psy.xxx = xxx;    // 设置参数,  关联函数参照5.1
               chip->bms_psy.getproperty= ppnp_vm_bms_power_get_property  // 调用方式  chip->bms_psy->get_property(chip->bms_psy,POWER_SUPPLY_PROP_CAPACITY, &ret);   
                      get_prop_bms_capacity(struct qpnp_bms_chip *chip)
                               report_state_of_charge(chip)
                                        report_vm_bms_soc(chip)
   power_supply_register(chip->dev, &chip->bms_psy)  // power_supply_register
   get_battery_voltage(chip, &vbatt)  // 获取电池电压      
             chip->debug_root = debugfs_create_dir("qpnp_vmbms", NULL)   // 创建debug路径
   ent = debugfs_create_file("bms_data", S_IFREG | S_IRUGO, chip->debug_root, chip,&bms_data_debugfs_ops);// 创建debugfile
   schedule_delayed_work(&chip->monitor_soc_work, 0); // 调度 SoC监控函数
       static void monitor_soc_work(struct work_struct *work)
   /* schedule a work to check if the userspace vmbms module has registered. Fall-back to voltage-based-soc reporting  if it has not.	 */
   schedule_delayed_work(&chip->voltage_soc_timeout_work,msecs_to_jiffies(chip->dt.cfg_voltage_soc_timeout_ms)) 

/* Probe   Success */  
```
### 主线二: SoC work loop
![loop](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/qcom/bms_9.jpg)
```bash        
         static void monitor_soc_work(struct work_struct *work)
                  /*将自定义设备结构体保存在文件指针的私有数据域中,以便访问设备时可以随时拿来使用*/
                (根据结构体成员的指针 work 找到对应结构体的指针， qpnp_bms_chip整个结构体类型，结构体成员（第一个参数）的类型)
                  struct qpnp_bms_chip *chip = container_of(work,struct qpnp_bms_chip,	monitor_soc_work.work); // 取出chip 
                  bms_stay_awake(&chip->vbms_soc_wake_source )//
                             wakeup_source_report_event(ws) // Report wakeup event using the given source.
                   calculate_delta_time(&chip->tm_sec, &chip->delta_time_s)  // 计算 delta time(elapsed_time 实耗时间)       
                   mutex_lock(&chip->last_soc_mutex)
                   rc = get_battery_voltage(chip, &vbat_uv)     // 如果电池存在,获取电池电压(vadc)
                   if (chip->dt.cfg_use_voltage_soc)   // lihuaqian: if( BMS device not opened )
		              calculate_soc_from_voltage(chip); // 通过电压计算SoC(state of charge 电量)
                                      if (voltage_based_soc == 100)
	                if (chip->dt.cfg_report_charger_eoc)    
		             report_eoc(chip);  // 上报eoc
                  else  
			      rc = get_batt_therm(chip, &batt_temp);      // 获取电池热量
                              new_soc = lookup_soc_ocv(chip, chip->last_ocv_uv,batt_temp);//  获得SoC(电量,见Battery Capacity Percent)
			      report_vm_bms_soc(chip);//update last_soc immediately 
                              power_supply_changed(&chip->bms_psy)  // 修改电池信息
	  pm_stay_awake(psy->dev);  //Notify the PM core that a wakeup event is being processed
	  schedule_work(&psy->changed_work);  //   schedule the changed_work function
                             low_soc_check(chip)  // low SOC configuration
                 schedule_delayed_work(&chip->monitor_soc_work,	msecs_to_jiffies(get_calculation_delay_ms(chip)));// schedule the work only if last_soc has not caught up with the calculated soc                                                                                                                                                                                                      or if we are using voltage based soc
```

### 主线三: Report  SoC
![report](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/qcom/bms_10.jpg)
```bash        
    static int report_vm_bms_soc(struct qpnp_bms_chip *chip)
            soc = chip->calculated_soc
            calculate_delta_time(&last_change_sec, &time_since_last_change_sec)
            charging = is_battery_charging(chip)
            if (charging..)
chip->catch_up_time_sec
chip->charge_start_tm_sec = last_change_sec;
            else
                   / * last_soc < soc  ... if we have not been charging at all since the last time this was called, report previous SoC. Otherwise, scale and catch up. */
                        ...
                        soc = scale_soc_while_chg(chip, charge_time_sec,chip->catch_up_time_sec,soc, chip->last_soc);  // scale and catch up
           check_eoc_condition(chip);// 检测电池 条件状况
			rc = report_eoc(chip);
           check_recharge_condition(chip) // 检测 充电 condition
           backup_ocv_soc(chip, chip->last_ocv_uv, chip->last_soc) //Backup the actual ocv (last_ocv_uv) and not the last_soc-interpolated ocv.
```




