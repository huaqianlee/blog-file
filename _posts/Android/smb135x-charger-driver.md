title: "高通 smb135x charger 驱动分析"
date: 2015-06-24 21:52:49
categories: Android
tags: [源码分析,Qualcomm]
---
## analysis log

<!--mroe-->
```bash
<3>[52515.763039] __smb135x_write: Writing 0x41=0x06
<3>[52515.774459] __smb135x_write: Writing 0x41=0x26
函数调用:    
static int __smb135x_write(struct smb135x_chg *chip, int reg,u8 val)
->smb135x_write(struct smb135x_chg *chip, int reg,u8 val) / smb135x_masked_write(struct smb135x_chg *chip, int reg,	u8 mask, u8 val)


<3>[52515.777868] fast_chg_handler: rt_stat = 0x00
<3>[52515.782184] usbin_uv_handler: chip->usb_present = 1 usb_present = 0
<3>[52515.788369] handle_usb_removal: setting usb psy type = 0
<3>[52515.793689] handle_usb_removal: setting usb psy present = 0
<3>[52515.799241] power_ok_handler: rt_stat = 0x00
<3>[52515.803472] src_detect_handler: chip->usb_present = 0 usb_present = 0
函数调用: 
fast_chg_handler(struct smb135x_chg *chip, u8 rt_stat)
usbin_uv_handler(struct smb135x_chg *chip, u8 rt_stat)
handle_usb_removal(struct smb135x_chg *chip)
(->usbin_uv_handler(struct smb135x_chg *chip, u8 rt_stat)/usbin_ov_handler(struct smb135x_chg *chip, u8 rt_stat)/determine_initial_status(struct smb135x_chg *chip))
static struct irq_handler_info handlers[]= 
{
...
			{
				.name		= "fast_chg",
				.smb_irq	= fast_chg_handler,
			},
			{
				.name		= "usbin_uv",
				.smb_irq	= usbin_uv_handler,
			},
...
}
->smb135x_irq_read(struct smb135x_chg *chip)
/static irqreturn_t smb135x_chg_stat_handler(int irq, void *dev_id)
->smb135x_chg_stat_handler(int irq, void *dev_id)
->smb135x_main_charger_probe(struct i2c_client *client,const struct i2c_device_id *id)

<3>[52515.809926] smb135x_chg_stat_handler: handler count = 4
<3>[52515.815104] smb135x_chg_stat_handler: batt psy changed
<3>[52515.820247] smb135x_chg_stat_handler: usb psy changed
<3>[52515.825260] smb135x_chg_stat_handler: dc psy changed
函数调用:
smb135x_chg_stat_handler(int irq, void *dev_id)
smb135x_external_power_changed(struct power_supply *psy)
->  smb135x_main_charger_probe(struct i2c_client *client,const struct i2c_device_id *id)/(force_irq_set(void *data, u64 val)/smb135x_resume(struct device *dev))

<6>[52515.836445] msm_hsusb msm_hsusb: CI13XXX_CONTROLLER_DISCONNECT_EVENT received
函数调用:
         kernel/drivers/usb/chipidea/ci13xxx_msm.c:186:		dev_info(dev, "CI13XXX_CONTROLLER_DISCONNECT_EVENT received\n");

<3>[52515.837146] smb135x_get_prop_batt_status: STATUS_4_REG=80
<3>[52515.841747] smb135x_get_prop_batt_status: STATUS_4_REG=80
函数调用:
smb135x_get_prop_batt_status(struct smb135x_chg *chip)
->smb135x_battery_get_property(struct power_supply *psy,enum power_supply_property prop,union power_supply_propval *val)/
     smb135x_parallel_get_property(...)

<3>[52515.847405] smb135x_external_power_changed: current_limit = 0
函数调用:
        smb135x_external_power_changed(struct power_supply *psy)

.....
```
## driver architecture
### the important structure
```bash
static struct i2c_driver smb135x_charger_driver = {
	.driver		= {
		.name		= "smb135x-charger",
		.owner		= THIS_MODULE,
		.of_match_table	= smb135x_match_table,    // get the dtsi profile
		.pm		= &smb135x_pm_ops,
	},
	.probe		= smb135x_charger_probe,
	.remove		= smb135x_charger_remove,
	.id_table	= smb135x_charger_id,
};
           /*represent an I2C slave device*/
struct i2c_client {
	unsigned short flags;		/* div., see below		*/
	unsigned short addr;		/* chip address - NOTE: 7bit	*/
					/* addresses are stored in the	*/
					/* _LOWER_ 7 bits		*/
	char name[I2C_NAME_SIZE];
	struct i2c_adapter *adapter;	/* the adapter we sit on	*/
	struct i2c_driver *driver;	/* and our access routines	*/
	struct device dev;		/* the device structure		*/
	int irq;			/* irq issued by device		*/
	struct list_head detected;
};
struct i2c_device_id {
	char name[I2C_NAME_SIZE];
	kernel_ulong_t driver_data;	/* Data private to the driver */
};

struct device_node {
	const char *name;
	const char *type;
	phandle phandle;
	const char *full_name;
        ...
}
struct smb135x_chg {
	struct i2c_client		*client;
	struct device			*dev;
	struct mutex			read_write_lock;
        ...
	/* psy */
	struct power_supply		*usb_psy;
	int				usb_psy_ma;
	struct power_supply		batt_psy;
	struct power_supply		dc_psy;
	struct power_supply		parallel_psy;
	struct power_supply		*bms_psy;
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
```



### driver analysis
```bash
# 注册驱动:
	if (is_parallel_charger(client))
	        smb135x_parallel_charger_probe(client, id);
	else
		smb135x_main_charger_probe(client, id); // 驱动注册入口函数
                chip = devm_kzalloc(&client->dev, sizeof(*chip), GFP_KERNEL);
	        chip->client = client;
	        chip->dev = &client->dev;   // get the dev
                smb_parse_dt(chip)     // parse DT nodes
      usb_psy = power_supply_get_by_name("usb"); // get usb Supply
    struct device *dev = class_find_device(power_supply_class, NULL, name,power_supply_match_device_by_name);
    dev_get_drvdata(dev)
     INIT_DELAYED_WORK(&chip->wireless_insertion_work,wireless_insertion_work);
     smb135x_read(chip, CFG_4_REG, &reg) // probe the device to check if its actually connected
     i2c_set_clientdata(client, chip);  // client->...->driver_datat = chip
     smb135x_chip_version_and_revision(chip) // judge the chip version(smb1357/1358....)
     dump_regs(chip) // read and display the register's value
     smb135x_regulator_init(chip) // initialize regulator(稳压器)
     smb135x_hw_init(chip) // initialize hardware(初始化芯片各种参数)
     determine_initial_status(chip) //determine init status
     .../* initialize Battery power_supply*/
     chip->batt_psy.get_property	= smb135x_battery_get_property;
     chip->batt_psy.set_property	= smb135x_battery_set_property;
     chip->batt_psy.external_power_changed = smb135x_external_power_changed;   // register external power  update online function
     chip->batt_psy.property_is_writeable = smb135x_battery_is_writeable;
     power_supply_register(chip->dev, &chip->batt_psy) // register Battery power Supply
     ....// get the profile and register the function
     power_supply_register(chip->dev, &chip->dc_psy); // register dc psy  
     devm_request_threaded_irq(struct device *dev, unsigned int irq, irq_handler_t handler, irq_handler_t thread_fn,unsigned long irqflags, 
                                                         const char *devname, void *dev_id)  // allocate(分配) an interrupt line for a managed device
               enable_irq_wake(client->irq); // control irq power management wakeup
               create_debugfs_entries(chip); // create debug 
```

