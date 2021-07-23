title: "Android不带电量计的电量计算"
date: 2015-01-21 20:10:01
categories: 
- Android Tree
- Kernel
tags:
- 源码分析
- Qualcomm
- Power
---
　　一直比较好奇，Android的电量是怎么计算出来的，今天就借用qualcomm平台的8916芯片研究了一下，因为其不带电量计，所以是通过一个bms系统计算出来的，下面就来详细分析一下计算方法。

## SOC（state of charge 荷电状态 - 电量） 
英文缩写:
FCC　　Full-charge capacity      
RC 　　Remaining capacity (剩余电量)
CC 　　Coulumb counter    
UUC　　Unusable capacity
RUC　　Remaining usable capacity    
SoC　　State of charge    
OCV　　Open circuit voltage
<!--more-->
SOC=(RC-CC-UUC)/(FCC-UUC)
RUC=RC-CC-UUC
## 电池电量决定因素

　　电池电量百分比主要有电池dtsi文件中百分比参数计算而得，如下：
```bash
	qcom,pc-temp-ocv-lut {
		qcom,lut-col-legend = <(-10) 0 25 50>;  // Temperature      lut-data（电池OCV ）的column
		qcom,lut-row-legend =  <100 89 78>,     // Capacity Percent        row
				<67 56 45>,
				<34 23 14>,
				<8 4 0>;
...				
		qcom,lut-data = 
		<4290	4285	4327	4328>,
		<4151	4162	4193	4208>,
		<4064	4072	4080	4016>,
		<3928	3943	3963	3980>,
		<3874	3881	3881	3894>,
		<3809	3834	3823	3820>,

		<3768	3785	3793	3792>, 
		<3733	3756	3784	3785>, 
		<3701	3723	3762	3761>, 
		<3624	3643	3739	3738>, 
		<3614	3623	3689	3688>, 	
		<3510	3499	3455	3458>; 
	
	};
```
## 关键结构

### dts table structure：

```bash
/**
 * struct pc_temp_ocv_lut -
 * @rows:	number of percent charge entries should be <= PC_TEMP_ROWS
 * @cols:	number of temperature entries should be <= PC_TEMP_COLS
 * @temp:	the temperatures at which ocv data is available in the table
 *		The temperatures must be in increasing order from 0 to rows.
 * @percent:	the percent charge at which ocv data is available in the table
 *		The  percentcharge must be in decreasing order from 0 to cols.
 * @ocv:	the open circuit voltage
 */
struct pc_temp_ocv_lut {
	int rows;
	int cols;
	int temp[PC_TEMP_COLS];
	int percent[PC_TEMP_ROWS];
	int ocv[PC_TEMP_ROWS][PC_TEMP_COLS];
};
```

## calculate percentcharge  function
```bash
int linear_interpolate(int y0, int x0, int y1, int x1, int x)
	if (y0 == y1 || x == x0)	return y0;
	if (x1 == x0 || x == x1)	return y1;
	return y0 + ((y1 - y0) * (x - x0) / (x1 - x0));
```
## 驱动分析

### 关键函数： 
```bash
// File:  qpnp-vm-bms.c
    lookup_soc_ocv(struct qpnp_bms_chip *chip, int ocv_uv, int batt_temp)、
soc_ocv = interpolate_pc(chip->batt_data->pc_temp_ocv_lut,batt_temp, ocv_uv / 1000);  //calculate the  capacity percent
soc_cutoff = interpolate_pc(chip->batt_data->pc_temp_ocv_lut,batt_temp, chip->dt.cfg_v_cutoff_uv / 1000);
soc_final = DIV_ROUND_CLOSEST(100 * (soc_ocv - soc_cutoff),(100 - soc_cutoff));
      DIV_ROUND_CLOSEST(x,y)    --->    (x-1>0) || (y-1>0) || x>0  ? (x+y/2)/y : (x-y/2)/y
if (!is_battery_charging(chip) && chip->current_now > 0) // 没有充电 重新计算电量
        iavg_ma = calculate_uuc_iavg(chip);
        fcc = interpolate_fcc(chip->batt_data->fcc_temp_lut,batt_temp);
        acc = interpolate_acc(chip->batt_data->ibat_acc_lut,	batt_temp, iavg_ma);
    both call ：
linear_interpolate(int y0, int x0, int y1, int x1, int x)
        soc_uuc = ((fcc - acc) * 100) / fcc;
	soc_uuc = adjust_uuc(chip, soc_uuc);
	soc_acc = DIV_ROUND_CLOSEST(100 * (soc_ocv - soc_uuc),(100 - soc_uuc));
        soc_final = soc_acc;
else
        ... // charging - reset all the counters
soc_final = bound_soc(soc_final) // 最终电量
```
### 百分比计算函数：
```bash
    interpolate_pc(chip->batt_data->pc_temp_ocv_lut,batt_temp, ocv_uv / 1000);  //calculate the  capacity percent
	if (batt_temp == pc_temp_ocv->temp[j] * DEGC_SCALE) {  /* found an exact match for temp in the table */
		for (i = 0; i < rows; i++)    // i: rows- Capacity Percent  j: columns-Temperature
                    ...
		    pc = linear_interpolate(pc_temp_ocv->percent[i],pc_temp_ocv->ocv[i][j],pc_temp_ocv->percent[i - 1],pc_temp_ocv->ocv[i - 1][j],ocv); // calculate 不匹配dts表格的percentcharge 
                    转换为公式见下公式一;                                

   /* batt_temp is within temperature for column j-1 and j */
  is_between(pc_temp_ocv->ocv[i][j],pc_temp_ocv->ocv[i+1][j], ocv)   // caculate temp1 percentcharge
         pcj = linear_interpolate(pc_temp_ocv->percent[i],pc_temp_ocv->ocv[i][j],pc_temp_ocv->percent[i + 1],pc_temp_ocv->ocv[i+1][j],	ocv);
                   转换为公式见下公式二;                         
            is_between(pc_temp_ocv->ocv[i][j-1],pc_temp_ocv->ocv[i+1][j-1], ocv)) // caculate temp2 percentcharge
		    pcj_minus_one = linear_interpolate(pc_temp_ocv->percent[i],pc_temp_ocv->ocv[i][j-1],pc_temp_ocv->percent[i + 1],pc_temp_ocv->ocv[i+1][j-1],ocv);
                    转换为公式见下公式三;                       
           if (pcj && pcj_minus_one) // temp1 and temp2 都存在，calculate percentcharge 
                    pc = linear_interpolate(pcj_minus_one,pc_temp_ocv->temp[j-1] * DEGC_SCALE,	pcj,pc_temp_ocv->temp[j] * DEGC_SCALE,batt_temp);
                    转换为公式见下公式四;                      
            否则：return pcj 、pcj_minus_one、其他临界值
```
### 公式一
![公式一](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/blog电量计算公式1.png)
### 公式二
![公式二](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/blog电量计算公式2.png)
### 公式三
![公式三](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/blog电量计算公式3.png)
### 公式四
![公式四](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/blog电量计算公式4.png)
