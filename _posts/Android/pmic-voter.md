title: "pmic voter"
date: 2019-05-15 23:48:59
categories: Android
tags: [源码分析,Qualcomm]
---
前不久在高通 SDM450 平台接触了 voter 机制（投票机制）。最近终于得空，结合一个问题简单研究了一下。现将研究流程简单记录一下,由于时间有限，所以是实用为目的，没有做详细的分析，不过结合着这篇分析和源码一起参考，应该能快速地应用 voter 做一些事情。

# voter
第一步是找到 voter 的实现代码，然后分析 voter 的机制。voter 的实现代码主要是为各种 voter 提供接口，我提炼了两个最关键的接口，如下：
```
# kernel/msm-4.9/drivers/power/supply/qcom/pmic-voter.c
/*
** vote 函数主要用来给 votable 添加投票选项
** votable: 投票的对象
** client_str: 投票者
** enabled: 投票者的内容（val）是否参与投票
** val: 投票内容
**/
int vote(struct votable *votable, const char *client_str, bool enabled, int val)
{
...
    switch (votable->type) { // type 的值来自于 create_votable()
	case VOTE_MIN: // 取投票对象所有内容的最小值
		vote_min(votable, client_id, &effective_result, &effective_id);
		break;
	case VOTE_MAX:
		vote_max(votable, client_id, &effective_result, &effective_id);
		break;
	case VOTE_SET_ANY:
		vote_set_any(votable, client_id,
				&effective_result, &effective_id);
		break;
...
}

/* 投票相关参数，可以在此文件中搜索此结构体的成员找到其值从哪儿来*/
struct votable {
	int			type;
...
	int			(*callback)(struct votable *votable,
	}
---> 

struct votable *create_votable(const char *name,
				int votable_type,
				int (*callback)(struct votable *votable,..)
{
    // 创建 votable, 引入 votable type 和 callback 函数
...
    /* 创建 debugfs*/
	debug_root = debugfs_create_dir("pmic-votable", NULL);
...
}
eg: 创建流入电池电流的投票对象
chip->fcc_votable = create_votable("FCC", VOTE_MIN,
				pl_fcc_vote_callback,
				chip);
```

<!--more-->
# pmic voter debugfs
通过 voter 的文件节点能够比较清晰的看出 voter 结构。如下：
```
# /sys/kernel/debug/pmic-votable/
cat status
FCC: HW_LIMIT_VOTER:			en=0 v=-22
FCC: BATT_PROFILE_VOTER:			en=1 v=1500000
FCC: SW_ICL_MAX_VOTER:			en=1 v=1500000
FCC: THERMAL_DAEMON_VOTER:			en=0 v=0
FCC: FCC_SOC_VOTER:			en=1 v=1000000
FCC: JEITA_VOTER:			en=1 v=1500000
FCC: STEP_CHG_VOTER:			en=0 v=0
FCC: TAPER_STEPPER_VOTER:			en=0 v=0
FCC: effective=FCC_SOC_VOTER type=Min v=1000000

```

# 一个问题案例
**[Description]**

设备在不同温度条件下有不同的电流限制，但是在测试设备时发现一个问题：电池温度升温过程中，设备并没有在 cool 零界限改变温度，而是再超过临界线 2~3 ℃ 的时候才做相应动作。

**[Root cause]**

默认的 jeita 标准相关代码有一个温度临界值保护并延迟改变电流值的设定，当达到临界值时并不马上改变电流限制，继续投票上一阶段的电流值，当温度达到定义的延迟温度时，再投票当前阶段的电流值。

**[Solution]**
如需要修改此问题的话，取消温度临界值保护（即将温度滞后值改为 0）即可。

详细情况如下：

## 每个阶段温度和电流值的定义
```
# kernel/msm-4.9/arch/arm64/boot/dts/qcom/vendor/qg-batterydata-xxx.dtsi

qcom,jeita-fcc-ranges = <50   150  800000  //阶段一  COOL
			151  450  1500000 // 阶段二 GOOD
			451  500  1400000>; // 阶段三 Warm
```

## 关键源码

```
# kernel/msm-4.9/drivers/power/supply/qcom/step-chg-jeita.c
/* 定义 jeita 标准延迟设定相关参数 */
chip->jeita_fcc_config->psy_prop = POWER_SUPPLY_PROP_TEMP;
chip->jeita_fcc_config->prop_name = "BATT_TEMP";
chip->jeita_fcc_config->hysteresis = 10;
	
/* jeita 生效函数 */
static int handle_jeita(struct step_chg_info *chip)
{
	rc = power_supply_get_property(chip->batt_psy,
			chip->jeita_fcc_config->psy_prop, &pval);
	rc = get_val(chip->jeita_fcc_config->fcc_cfg,
		chip->jeita_fcc_config->,
		chip->jeita_fcc_index,
		pval.intval,
		&chip->jeita_fcc_index,
		&fcc_ua);
		
	/* 投票获取到的电流值 */	
	vote(chip->fcc_votable, JEITA_VOTER, fcc_ua ? true : false, fcc_ua);
}

/* 获取当前应投票的电流值 */
get_val(...) 	
{
	/*
	 * Check for hysteresis if it in the neighbourhood
	 * of our current index.
	 */
	if (*new_index == current_index + 1) {
	    /* 当温度小于临界值 + 延迟时，继续使用上一阶段的电流值
		if (threshold < range[*new_index].low_threshold + hysteresis) {
			/*
			 * Stay in the current index, threshold is not higher
			 * by hysteresis amount
			 */
			*new_index = current_index;
			*val = range[current_index].value;
		}
	} else if (*new_index == current_index - 1) {
		if (threshold > range[*new_index].high_threshold - hysteresis) {
			/*
			 * stay in the current index, threshold is not lower
			 * by hysteresis amount
			 */
			*new_index = current_index;
			*val = range[current_index].value;
		}
	}
	}
```
