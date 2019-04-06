title: "高通 linear charger 驱动分析"
date: 2015-06-24 21:53:29
categories: Android
tags: [源码分析,Qualcomm]
---
> File :  qpnp-linear-charger.c
acc: alam charger current (not sure, think so now)　
 

## QPNP Linear Charger Blocks
![lcb](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/qcom/linearcharger1.jpg)        

<!--more-->
## LBC Initialization Flowchart
![lbc](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/qcom/linearcharger2.jpg)  
lbc - linear Battery charger  (not sure)

## 架构分析
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

struct qpnp_lbc_chip {    // device information
	struct device			*dev;
	struct spmi_device		*spmi;
        ...
}
struct power_supply {
	const char *name;
	enum power_supply_type type;
	enum power_supply_property *properties;
	...
        int (*get_property)(...)
        int (*set_property)(...)
        ...       /* private */      struct device *dev;
      ...
}
/* Resources are tree-like, allowing nesting etc.. */(资源树,允许嵌套)
struct resource {
	resource_size_t start;
	resource_size_t end;
	const char *name;
	unsigned long flags;
	struct resource *parent, *sibling, *child;
};
struct spmi_resource { //spmi_resource for one device_node
	struct resource		*resource;
	u32			num_resources;
	struct device_node	*of_node;
	const char		*label;
};
```
### Interface between QPNP charger and device tree
```bash
        - struct qpnp_lbc_chip // Stores device information obtained from the device tree 

        - ​SPMI register access API
            qpnp_lbc_read(struct qpnp_lbc_chip *chip, u8 *val, u16 base, int count);
            qpnp_lbc_write(struct qpnp_lbc_chip *chip, u8 *val, u16 base, int count);
            qpnp_lbc_masked_write(struct qpnp_lbc_chip *chip, u8 *val,u16 base, int count);
```            
### Power Supply Framework to Export Information to User Space
```bash
       - Three power supply interfaces are in qpnp-linear-charger
- Maintained by qpnp-linear-charger.c
       struct power_supply batt_psy; – Used to update the battery status
- Only updated by qpnp-linear-charger.c
       struct power_supply usb_psy; – Used to update the USB status
       struct power_supply bms_psy; – Indirectly calls the APIs implemented in qpnp-vm-bms.c
```       
### QPNP Charger – Update Power Supply Interfaces
```bash
power_supply_changed(chip->usb_psy);
qpnp_lbc_usbin_valid_irq_handler()
power_supply_set_present(chip->usb_psy, chip->usb_present);
power_supply_changed(&chip->batt_psy);
qpnp_lbc_batt_pres_irq_handler()
qpnp_lbc_fastchg_irq_handler()
qpnp_lbc_chg_done_irq_handler()
```
### Association DTSI 
![dts](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/qcom/linearcharger3.jpg)      
## 驱动分析
### 主线一 : 
```bash
        入口函数: module_init(qpnp_lbc_init)
                                _init qpnp_lbc_init(void)
                                        spmi_driver_register(&qpnp_lbc_driver); // 注册spmi 驱动
        /*Driver Probe function*/
        static int qpnp_lbc_probe(struct spmi_device *spmi)
                usb_psy = power_supply_get_by_name("usb");  // 获取USB充电支持 struct power_supply *usb_psy;
                        struct device *dev = class_find_device(power_supply_class, NULL, name,power_supply_match_device_by_name);
                        dev_get_drvdata(dev) //return dev->p->driver_data
        chip = devm_kzalloc(&spmi->dev, sizeof(struct qpnp_lbc_chip),GFP_KERNEL);//分配空间给struct qpnp_lbc_chip *chip;
	dev_set_drvdata(&spmi->dev, chip);
	device_init_wakeup(&spmi->dev, 1);
        INIT_WORK(&chip->vddtrim_work, qpnp_lbc_vddtrim_work_fn);  // 关联vdd调整function
        alarm_init(&chip->vddtrim_alarm, ALARM_REALTIME, vddtrim_callback) // Initialize an alarm structure
        qpnp_charger_read_dt_props(chip)// Get all device-tree properties
        spmi_for_each_container_dev(spmi_resource, spmi) // 遍历spmi dev
                resource = spmi_get_resource(spmi, spmi_resource,IORESOURCE_MEM, 0); // get a resource for a device
                qpnp_lbc_read(chip, resource->start + PERP_SUBTYPE_REG,&subtype, 1);  // Peripheral subtype read 读取外围子设备
                switch (subtype)
                    .....  //根据不同的外围设备 进行get  irqs等操作
        qpnp_disable_lbc_charger(chip)  // disable externalcharger
        /* Initialize h/w */
        qpnp_lbc_misc_init(chip)
        qpnp_lbc_chg_init(chip)
        qpnp_lbc_bat_if_init(chip)
        qpnp_lbc_usb_path_init(chip)
        if (chip->bat_if_base) // 如果电池接口外设存在
                .../ chip 参数\function association
                qpnp_batt_power_get_property
                qpnp_batt_power_set_property
                qpnp_batt_property_is_writeable
                qpnp_batt_external_power_changed
                power_supply_register(chip->dev, &chip->batt_psy) // power Supply device register

                qpnp_lbc_jeita_adc_notification  // notification
                qpnp_adc_tm_channel_measure(chip->adc_tm_dev,&chip->adc_param); // request ADC
        qpnp_lbc_bat_if_configure_btc(chip) // configure btc        
        determine_initial_status(chip); /* Get/Set charger's initial status */
        qpnp_lbc_request_irqs(chip); // initialize LBC MISC
        /* Configure initial alarm for VDD trim */ 配置initial vdd调整报警
        alarm_start_relative(&chip->vddtrim_alarm, kt);//Sets a relative alarm to fire
```        
### 主线二 : 
```bash
            qpnp_batt_power_get_property
                    get_prop_batt_status(chip); // 判断修改电池状态（充电 完成 等）
if (qpnp_lbc_is_usb_chg_plugged_in(chip) && chip->chg_done) //return POWER_SUPPLY_STATUS_FULL;
rc = qpnp_lbc_read(chip, chip->chgr_base + INT_RT_STS_REG,&reg_val, 1);
                    get_prop_capacity(chip)
                            battery_status = get_prop_batt_status(chip);   // 判断修改电池状态（充电 完成 等）
		      charger_in = qpnp_lbc_is_usb_chg_plugged_in(chip); //USB插入               
```


