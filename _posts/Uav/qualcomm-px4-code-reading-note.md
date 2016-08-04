title: "高通px4代码阅读笔记"
date: 2016-05-11 21:45:25
categories: Uav
tags: 
 - PX4
 - 源码分析
---
**像这种庞大系统的代码， 我一般喜欢先大致了解一下代码结构，然后按照执行流程阅读分析。我阅读的是高通8074平台的px4代码。**

代码地址：[ATLFlight/Firmware](https://github.com/ATLFlight/Firmware)
参考文档：[px4 devguide](http://dev.px4.io/tutorial-hello-sky.html?q=)

>由于没有足够的时间再去细细研究, 所以只有这么一个粗略的笔记.

============================================================================================================
##关键路径及文件
```bash
W:\uav\Firmware\src\modules\mavlink   //  信息数据处理
mavlink_main.cpp
mavlink_receiver.cpp

FastRPC   --  aDSP 与 apps 之间远程调用
1. 共享内存（不包括L1/L2缓存）
2. aDSP中能支持有限的物理映射

W:\uav\Firmware\src\modules\muorb\
adsp 
Krait

W:\uav\Firmware\posix-configs\eagle\flight    // config 文件

W:\uav\Firmware\src\modules  // 功能模块

W:\uav\Firmware\makefiles\ 


W:\uav\Firmware\src\drivers\rc_receiver\rc_receiver_main.cpp   // 遥控器

W:\uav\Firmware\src\drivers\device\vdev.cpp   # Virtual character device base class.
mavilink、uorb 继承于此类
```
<!--more-->
##按执行调用（log）顺序阅读
============================================================================================================

###APPS Processor
执行指令： ./mainapp mainapp.config  - （main.cpp + W:\uav\Firmware\posix-configs\eagle\flight\mainapp-flight.config）
```bash
W:\uav\Firmware\src\platforms\posix\main.cpp 
int main(int argc, char **argv)
    px4::init_once()
        pthread_self()                  # expand params table and copy own params to shared memory
        init_own_params()           # copy other proc params from shared memory
    process_line(line)         # 执行mainapp.config中的命令
    getline(cin, mystr)       # 定义shell， 并读取输入  “pxh>”
```
执行时打印的log如下：
```log
px4muorbKraitWrapper.cpp （C:\Qualcomm\Hexagon_SDK\2.0\flight_controller\krait\inc\px4muorb_KraitRpcWrapper.hpp）

W:\uav\apq8074-le-1-0_ap_standard_oem\apps_proc\oe-core\build\tmp-eglibc\work\cortexa8hf-vfp-neon-linux-gnueabi\adsprpc\1.0-r0\adsprpc-1.0\src
fastrpc_apps_user.c
listener_android.c
rpcmem.c  （rpcmem_alloc 分配 ION memory）

INFO  Shell id is 3069956096
INFO  Starting shared memory param sync

INFO  param loading done

App name: mainapp
pxh>  （shell ？）
apq8074-le-1-0_ap_standard_oem/apps_proc/oe-core/build/tmp-eglibc/work/cortexa8hf-vfp-neon-linux-gnueabi/adsprpc/1.0-r0/adsprpc-1.0/src/listener_android.c
```
mainapp.config的内容如下：
```bash
uorb start
muorb start
mavlink start -u 14556
sleep 1
mavlink stream -u 14556 -s HIGHRES_IMU -r 50
mavlink stream -u 14556 -s ATTITUDE -r 50
mavlink boot_complete
```


### ADSP
adsp端打印的log如下：
```log
symbol.c （链接ELF（ Executable and Linkable Format） 和 object）
reloc.c      // two c file maybe come from apps_proc
W:\uav\Firmware\src\modules\muorb\adsp\px4muorb.cpp （px4muorb_orb_initialize）
      - W:\uav\Firmware\src\platforms\qurt\px4_layer\main.cpp （ dspal_entry）
        W:\uav\Firmware\posix-configs\eagle\flight\px4-flight.config -->（adb push） /usr/share/data/adsp/px4.config（linaro中文件， 由px4-flight.config改名得来）  --> “/dev/fs/px4.config“（W:\uav\Firmware\src\platforms\qurt\px4_layer\main.cpp 中引用）

W:\uav\Firmware\src\modules\uORB\uORBManager_posix.cpp  -->加载 DeviceNode
```

adsp端main.cp源码如下：
```bash
#W:\uav\Firmware\src\platforms\qurt\px4_layer\main.cpp 
int dspal_main(int argc, char *argv[])
    dspal_entry( int argc, char* argv[] )
        px4::init_once()
            init_own_params()
            init_other_params()
        process_commands(apps, get_commands())  # 执行px4-flight.config中的命令
            PARAM_DEFINE_INT32(MAV_TYPE,2)  # commander需要用到的parameter，由mavlink创建，因为mavilink没有运行在qurt，所以需要手动定义以便在commander中能够使用， "2" is for quadrotor（枚举值，四轴飞行器），MAV_TYPE - enum
            run_cmd(apps, appargs)
        void qurt_external_hook(void) __attribute__((weak))      #start external function
```

adsp端配置文件如下：
```bash
# W:\uav\Firmware\posix-configs\eagle\flight\px4-flight.config
uorb start
param set xx  xx
commander start 

param set RC_RECEIVER_TYPE 1    # 为c中相关的地方提供参数， 类似于外部宏定义 ?
/**
**  _params_handles.rc_receiver_type	=	param_find("RC_RECEIVER_TYPE"); # W:\uav\Firmware\src\drivers\rc_receiver\rc_receiver_main.cpp
**  PARAM_DEFINE_INT32(RC_RECEIVER_TYPE, 1);  # W:\uav\Firmware\src\drivers\rc_receiver\rc_receiver_params.c)
**/

rc_receiver start -D /dev/tty-1

attitude_estimator_q start
position_estimator_inav start
mc_pos_control start
mc_att_control start


param set xx  xx
sensors start

param set xx  xx

mpu9x50 start -D /dev/spi-1    --->  driver/mpu9x50 ---> module/sensors ---> ... ---> drivers/uart_esc
uart_esc start -D /dev/tty-2
csr_gps start -D /dev/tty-3
pressure start -D /dev/i2c-2
list_devices
list_files
list_tasks
list_topics
```


### uorb & muorb
uorb&muorb是负责数据传输的模块。
```bash
# 关键路径
W:\uav\Firmware\src\modules\uORB\uORBCommon.hpp
```

#### uorb start
```bash
W:\uav\Firmware\src\modules\uORB\uORBMain.cpp
int uorb_main(int argc, char *argv[])
    g_dev = new uORB::DeviceMaster(uORB::PUBSUB); 
        ...    (W:\uav\Firmware\src\modules\uORB\uORBDevices_posix.hpp)
    g_dev->init()
        VDev->init()              W:\uav\Firmware\src\drivers\device\vdev.cpp  , 父类
            device->init()         W:\uav\Firmware\src\drivers\device\vdev.cpp, 父类
            register_driver(_devname, (void *)this); # 注册驱动    
```

W:\uav\Firmware\src\modules\uORB\uORBDevices_posix.hpp
```bash
class uORB::DeviceNode : public device::VDev
{
virtual int   open(device::file_t *filp);
virtual int   ioctl(device::file_t *filp, int cmd, unsigned long arg);
...
static ssize_t    publish(const orb_metadata *meta, orb_advert_t handle, const void *data);
...
int16_t process_add_subscription(int32_t rateInHz);
...


/**
 * Master control device for ObjDev.
 *
 * Used primarily to create new objects via the ORBIOCCREATE
 * ioctl.
 */
class uORB::DeviceMaster : public device::VDev
{
public:
	DeviceMaster(Flavor f);
	~DeviceMaster();

	static uORB::DeviceNode *GetDeviceNode(const char *node_name);

	virtual int   ioctl(device::file_t *filp, int cmd, unsigned long arg);
private:
	Flavor      _flavor;
	static std::map<std::string, uORB::DeviceNode *> _node_map;  # DeviceNode 集合 
};
```
　
#### muorb start
```bash
uORBDevices_posix.cpp  
        ---> W:\uav\Firmware\src\drivers\device\vdev_posix.cpp      
                 uorb  px4_write() px4_read() px4_ioctl() px4_poll() 等底层实现 ？
```

##### Krait muorb
```bash
int muorb_main(int argc, char *argv[]) (W:\uav\Firmware\src\modules\muorb\krait\muorb_main.cpp)
"start"
    uORB::Manager::get_instance()->set_uorb_communicator(uORB::KraitFastRpcChannel::GetInstance()); # register the fast rpc channel with UORB.
        uORB::Manager *uORB::Manager::get_instance() (W:\uav\Firmware\src\modules\uORB\uORBDevices_posix.cpp)
        static uORB::KraitFastRpcChannel *GetInstance(W:\uav\Firmware\src\modules\muorb\krait\uORBKraitFastRpcChannel.hpp) # 获取uORB::KraitFastRpcChannel实例, invoke constructor
    uORB::KraitFastRpcChannel::GetInstance()->Start(); # start the KaitFastRPC channel thread.
        void uORB::KraitFastRpcChannel::Start() (W:\uav\Firmware\src\modules\muorb\krait\uORBKraitFastRpcChannel.cpp)  # start 

"stop"  
    void uORB::KraitFastRpcChannel::Stop()
```

####muorb通信
```
==========================================================================================================================
 Krait muorb                                         (invoke)---->                                             adsp muorb
(uORBKraitFastRpcChannel.cpp)                                                                             (adsp\px4muorb.cpp)
==========================================================================================================================
```

W:\uav\Firmware\src\modules\muorb\krait\uORBKraitFastRpcChannel.hpp
```bash
namespace uORB
{
class KraitFastRpcChannel;
}
class uORB::KraitFastRpcChannel : public uORBCommunicator::IChannel --> private  constructor. 

static uORB::KraitFastRpcChannel *GetInstance (# W:\uav\Firmware\src\modules\muorb\krait\uORBKraitFastRpcChannel.hpp)
    uORB::KraitFastRpcChannel::KraitFastRpcChannel() (W:\uav\Firmware\src\modules\muorb\krait\uORBKraitFastRpcChannel.cpp) # constructor begin
        _KraitWrapper.Initialize();
           int px4muorb_orb_initialize() （W:\uav\Firmware\src\modules\muorb\adsp\px4muorb.cpp） # 调用adsp中initial
                dspal_main(argc, argv); （W:\uav\Firmware\src\platforms\qurt\px4_layer\main.cpp）
    int16_t uORB::KraitFastRpcChannel::add_subscription(const char *messageName, int32_t msgRateInHz)
    ...
```

####uorb通信
```bash
==========================================================================
uorb      (invoke)---->    krait muorb      (invoke)---->     adsp muorb
==========================================================================
```

#### add subscriber
```bash
void uORB::DeviceNode::add_internal_subscriber() (W:\uav\Firmware\src\modules\uORB\uORBDevices_posix.cpp  # 调用adsp 和 Krait中muorb中实现的 接口 ？)
    int16_t uORB::KraitFastRpcChannel::add_subscription(const char *messageName, int32_t msgRateInHz) (W:\uav\Firmware\src\modules\muorb\krait\uORBKraitFastRpcChannel.cpp)
        int px4muorb_add_subscriber(const char *name) (W:\uav\Firmware\src\modules\muorb\adsp\px4muorb.cpp)
            uORB::FastRpcChannel::GetInstance(); // 获取adsp FastRpcChannel 实例， 构造方法 
                uORB::FastRpcChannel::FastRpcChannel()
                    初始化...
                    _RemoteSubscribers.clear(); # std::set<std::string> _RemoteSubscribers   远端订阅集？
	    channel->AddRemoteSubscriber(name);
                _RemoteSubscribers.insert(messageName); # 插入一个message
            uORBCommunicator::IChannelRxHandler *rxHandler  = channel->GetRxHandler();
            rxHandler->process_add_subscription(name, 0);
                virtual int16_t process_add_subscription(const char *messageName, int32_t msgRateInHz) = 0;   #无源文件， 库
```



W:\uav\Firmware\src\modules\muorb\adsp\uORBFastRpcChannel.hpp
```bash
namespace uORB
{
class FastRpcChannel;
}
class uORB::FastRpcChannel : public uORBCommunicator::IChannel
{
}
```

W:\uav\Firmware\src\modules\uORB\uORBCommunicator.hpp
```bash
/**
 * Class passed to the communication link implement to provide callback for received
 * messages over a channel.
 */
class uORBCommunicator::IChannelRxHandler
 	virtual int16_t process_add_subscription(const char *messageName, int32_t msgRateInHz) = 0;
```

W:\uav\Firmware\src\modules\uORB\uORBDevices_posix.cpp  ( apps processor 数据交互 ？)
```bash
void uORB::DeviceNode::add_internal_subscriber()
int16_t uORB::DeviceNode::process_add_subscription(int32_t rateInHz)
    uORBCommunicator::IChannel *uORB::Manager::get_uorb_communicator(void) # 获取 uORBCommunicator::IChannel
        ch->send_message(_meta->o_name, _meta->o_size, _data);

int uORB::DeviceNode::ioctl(device::file_t *filp, int cmd, unsigned long arg)
read()  
write()
int uORB::DeviceMaster::ioctl(device::file_t *filp, int cmd, unsigned long arg)  # create new objects 
	switch (cmd) {
	case ORBIOCADVERTISE: {
                /* construct the new node */
		node = new uORB::DeviceNode(meta, objname, devpath, adv->priority);                
		_node_map[std::string(nodepath)] = node; // add to the node map;.
```


W:\uav\Firmware\src\modules\uORB\uORBManager_posix.cpp （px4_ioctl）
```bash
int16_t uORB::Manager::process_add_subscription(const char *messageName, int32_t msgRateInHz)

orb_advert_t uORB::Manager::orb_advertise_multi(const struct orb_metadata *meta, const void *data, int *instance,int priority)
    int px4_ioctl(int fd, int cmd, unsigned long arg) (W:\uav\Firmware\src\drivers\device\vdev_posix.cpp)
        dev->ioctl(filemap[fd], cmd, arg);
            int VDev::ioctl(file_t *filep, int cmd, unsigned long arg)( W:\uav\Firmware\src\drivers\device\vdev.cpp)
```


W:\uav\Firmware\src\drivers\drv_orb_dev.h

W:\uav\Firmware\src\drivers\device\vdev.cpp

 编译后执行程序 打印路径变成 
```bash
W:\uav\apq8074-le-1-0_ap_standard_oem\apps_proc\oe-core\build\tmp-eglibc\work\cortexa8hf-vfp-neon-linux-gnueabi\adsprpc\1.0-r0\adsprpc-1.0\src
W:\uav\apq8074-le-1-0_ap_standard_oem\apps_proc\adsprpc\src\listener_android.c
W:\uav\apq8074-le-1-0_ap_standard_oem\apps_proc\adsprpc\src\adsp_listener_stub.c
W:\uav\apq8074-le-1-0_ap_standard_oem\apps_proc\adsprpc\src\fastrpc_apps_user.c
W:\uav\apq8074-le-1-0_ap_standard_oem\apps_proc\adsprpc\src\rpcmem.c
```


### 数据传输流程
adsp --> libmpu9x50.so->mpu9x50_main.cpp->orb
```
W:\uav\Firmware\src\drivers\mpu9x50\mpu9x50_main.cpp
int mpu9x50_main(int argc, char *argv[]) (device = myoptarg=dev/spi-1 )
    mpu9x50::start();
        void task_main(int argc, char *argv[])
            ...    (libmpu9x50.so,  adsp 操作接口)
            create_pubs()    # 创建 uorb publications   
                  _gyro_pub = orb_advertise(ORB_ID(sensor_xxx), &_xxx);     # 通知 公布主题	
	    _params_sub = orb_subscribe(ORB_ID(parameter_update));     # 订阅 parameter_update topic
	    while (!_task_should_exit) {
mpu9x50_get_data(&_data)
parameter_update_poll(); # 轮询 parameter update (W:\uav\Firmware\src\modules\uORB\topics\parameter_update.h)
publish_reports(); # 发布sensors主题
```

### commander
飞行安全管理， 订阅相关主题， 用来检查飞行安全，并做相应处理，。。。。。
```bash
W:\uav\Firmware\src\modules\commander\commander.cpp
int commander_main(int argc, char *argv[])
    int commander_thread_main(int argc, char *argv[])
        ...      # set parameters  -> mavlink
        # 初始化vehicle_status_s (W:\uav\Firmware\src\modules\uORB\topics\vehicle_status.h)
        main_states_str[vehicle_status_s::MAIN_STATE_MAX]; 
        arming_states_str[] / nav_states_str[]
        ...
        orb_advertise(ORB_ID(vehicle_status), &status); # 公布vehicle_status
        orb_advertise(ORB_ID(vehicle_control_mode), &control_mode);
        orb_advertise(ORB_ID(actuator_armed), &armed);
        dm_read(DM_KEY_MISSION_STATE, 0, &mission, sizeof(mission_s)
         orb_advertise(ORB_ID(offboard_mission), &mission);
         orb_publish(ORB_ID(offboard_mission), mission_pub, &mission);

        /* Start monitoring loop */
        rc_calibration_check(mavlink_fd);   #遥控器校准？
        orb_subscribe(ORB_ID(safety))
        orb_subscribe(ORB_ID(mission_result))
        orb_subscribe(ORB_ID(geofence_result))
        orb_subscribe(ORB_ID(manual_control_setpoint)) # 订阅manual control data
        orb_subscribe(ORB_ID(offboard_control_mode))
        orb_subscribe(ORB_ID(vehicle_global_position)) #订阅global position
        orb_subscribe(ORB_ID(vehicle_local_position))
        orb_subscribe(ORB_ID(vehicle_land_detected))

        orb_subscribe(ORB_ID(vehicle_gps_position))
        orb_subscribe(ORB_ID(sensor_combined))
        orb_subscribe(ORB_ID(differential_pressure))
        orb_subscribe(ORB_ID(vehicle_command))
        orb_subscribe(ORB_ID(parameter_update))
        orb_subscribe(ORB_ID(battery_status))
        orb_subscribe(ORB_ID(subsystem_info))
        orb_subscribe(ORB_ID(position_setpoint_triplet))
        orb_subscribe(ORB_ID(system_power))
        orb_subscribe(ORB_ID_VEHICLE_ATTITUDE_CONTROLS)
        orb_subscribe(ORB_ID(vtol_vehicle_status))

        param_get(_param_sys_type, &(status.system_type)) # update vehicle status(vehicle_status_s ) to find out vehicle type (required for preflight checks)
        # Run preflight check
        
        commander_boot_timestamp = hrt_absolute_time() # 获取启动时间戳

        pthread_create(&commander_low_prio_thread, &commander_low_prio_attr, commander_low_prio_loop, NULL);
            px4_poll(&fds[0], (sizeof(fds) / sizeof(fds[0])), 1000)
            orb_copy(ORB_ID(vehicle_command), cmd_sub, &cmd)
            # handel command
        while()
            更新 parameter
            orb_check(param_changed_sub, &updated)  # 检查主题是否更新， 每次获取copy前执行， 或者执行poll()
            orb_copy(ORB_ID(parameter_update), param_changed_sub, &param_changed) # 从订阅主题中获取更新数据存在param_changed
            通过parameters获取值？
            orb_copy(ORB_ID(manual_control_setpoint), sp_man_sub, &sp_man) # 获取订阅主题manual_control_setpoint 数据
            orb_copy(ORB_ID(offboard_control_mode), offboard_control_mode_sub, &offboard_control_mode)

            orb_subscribe_multi(ORB_ID(telemetry_status), i)  #  订阅多个不同来源的 telemetry_status主题（最多四个）   遥控器 ？
            orb_copy(ORB_ID(telemetry_status), telemetry_subs[i], &telemetry)

            orb_copy(ORB_ID(sensor_combined), sensor_sub, &sensors)
            orb_copy(ORB_ID(differential_pressure), diff_pres_sub, &diff_pres)
            orb_copy(ORB_ID(system_power), system_power_sub, &system_power)
            orb_copy(ORB_ID(safety), safety_sub, &safety)
            orb_copy(ORB_ID(vtol_vehicle_status), vtol_vehicle_status_sub, &vtol_status) # 垂直起降
            orb_copy(ORB_ID(vehicle_global_position), global_position_sub, &gpos)
            orb_copy(ORB_ID(vehicle_local_position), local_position_sub, &local_position)
            orb_copy(ORB_ID(vehicle_land_detected), land_detector_sub, &land_detector)
            orb_copy(ORB_ID(battery_status), battery_sub, &battery); # 后面会根据电池状态做一些判断和处理
	    orb_copy(ORB_ID_VEHICLE_ATTITUDE_CONTROLS, actuator_controls_sub, &actuator_controls)
            orb_copy(ORB_ID(subsystem_info), subsys_sub, &info)
            orb_copy(ORB_ID(position_setpoint_triplet), pos_sp_triplet_sub, &pos_sp_triplet)
            orb_copy(ORB_ID(vehicle_gps_position), gps_sub, &gps_position)
            orb_copy(ORB_ID(mission_result), mission_result_sub, &mission_result)
            orb_copy(ORB_ID(geofence_result), geofence_result_sub, &geofence_result)
            遥控器输入信号检查

            set_main_state_rc(&status, &sp_man)  # manual_control_setpoint主题数据， MANUAL/ALTCTL/POSCTL 模式处理及反馈

            orb_copy(ORB_ID(vehicle_command), cmd_sub, &cmd) # 获取cmd    
            handle_command(&status, &safety, &cmd, &armed, &_home, &global_position, &local_position, &home_pub)  # 处理cmd

            # publish states (armed, control mode, vehicle status) at least with 5 Hz
            set_control_mode();
            orb_publish(ORB_ID(vehicle_control_mode), control_mode_pub, &control_mode);
            orb_publish(ORB_ID(vehicle_status), status_pub, &status);
            orb_publish(ORB_ID(actuator_armed), armed_pub, &armed);
```
W:\uav\Firmware\src\platforms\ros\nodes\commander\commander.cpp  （与上一commander.cpp 对应  ？）

W:\uav\Firmware\src\drivers\px4io\px4io.cpp    


### Mavlink
int mavlink_main(int argc, char *argv[]) # W:\uav\Firmware\src\modules\mavlink\mavlink_main.cpp
```bash
"start"
    Mavlink::start(int argc, char *argv[])
        px4_task_spawn_cmd( )
            Mavlink::start_helper( )
	        Mavlink::task_main(int argc, char *argv[])
                    px4_getopt(argc, argv, "b:r:d:u:m:fpvwx", &myoptind, &myoptarg)  #  "-u"  set udp
                    px4_open(MAVLINK_LOG_DEVICE, 0) # 创建设备节点， 发送log消息	
                    MavlinkReceiver::receive_start(this)	  # 创建 MavlinkReceiver线程
                    MavlinkOrbSubscription *param_sub     # Mavlink  Orb    Subscription 类  
                    = add_orb_subscription(ORB_ID(parameter_update));
                    add_orb_subscription(ORB_ID(vehicle_status))
                    status_sub->update(&status_time, &status)  # 调用MavlinkOrbSubscription 中update()， 获取比status_time新的数据
                    根据mode添加默认数据流
                    ...
                    LL_APPEND(_mavlink_instances, this) # 添加mavilink实例链表，初始化等？
                    init_udp(); # 如果为udp模式，初始化socket  , 后面也有初始化串口等操作
                    while( )
                        if (status_sub->update(&status_time, &status)) 			    			    set_hil_enabled(status.hil_state == vehicle_status_s::HIL_STATE_ON)  # switch HIL mode if required
			    set_manual_input_mode_generation(status.rc_input_mode == vehicle_status_s::RC_IN_MODE_GENERATED); # 设置为手动输入生成模式，if true， 通过手动输入mavilink消息在系统总线生成RC_INPUT消息    
                        check for requested subscriptions
                        configure_stream(_subscribe_to_stream, _subscribe_to_stream_rate)
                        stream->update(t); # 更新数据流
                        通过其他uarts 或者FTP(File Transfer Protocol) worker 传输消息
			message_buffer_get_ptr((void **)&read_ptr, &is_part);
                        ...
                        # 释放close所有设备消息


"stream"
    Mavlink::stream_command(int argc, char *argv[])
        strcmp(argv[i], "-s")
            stream_name = argv[i + 1];  # 配置数据流名如： HIGHRES_IMU，ATTITUDE
        strcmp(argv[i], "-r")
            rate = strtod(argv[i + 1], nullptr);  # 配置传输速率
        strcmp(argv[i], "-u")
            配置udp端口
    
        get_instance_for_device(device_name);  # "/dev/ttyS1" ， 与下二选一
        get_instance_for_network_port(network_port); # 获取数据传输文件实例， 此为udp
        inst->configure_stream_threadsafe(stream_name, rate) # orb订阅在主线程中完成，set _subscribe_to_stream和 _subscribe_to_stream_rate在mavilink主循环中取值
            _subscribe_to_stream_rate = rate;
            _subscribe_to_stream = s;  # stream_name

"boot_complete"
    set_boot_complete() { _boot_complete = true; }
```

### Mavlink Reiceiver
MavlinkReceiver::receive_start(Mavlink *parent)  # W:\uav\Firmware\src\modules\mavlink\mavlink_receiver.cpp
```bash
    *MavlinkReceiver::start_helper(void *context)
    MavlinkReceiver *rcv = new MavlinkReceiver((Mavlink *)context)
    rcv->receive_thread(NULL) # 创建接收线程
        if从串口读取 ::read(uart_fd, buf, sizeof(buf))    
        if从udp读取  recvfrom(_mavlink->get_socket_fd(), buf, sizeof(buf), 0, (struct sockaddr *)&srcaddr, &addrlen); 
        解析接收的数据  if mavlink_parse_char(_mavlink->get_channel(), buf[i], &msg, &status)  成功
        handle_message(&msg) # 处理通用信息和命令
            handle_message_manual_control(msg); # case MAVLINK_MSG_ID_MANUAL_CONTROL
            mavlink_msg_manual_control_decode(msg, &man); # 解码手动控制信息到结构体man
            处理转换手动控制信息
            orb_advertise(ORB_ID(input_rc), &rc) # 公布input_rc主题（远程输入消息）
            orb_publish(ORB_ID(input_rc), _rc_pub, &rc); # 发送主题  （sensors.cpp中订阅接收主题， 解析后再发布出去，传到下一级操作？）

        _mavlink->handle_message(&msg) # 处理父对象包

        _mavlink->count_rxbytes(nread) # 接收信息计数
```

W:\uav\Firmware\src\modules\mavlink\mavlink_messages.cpp  # 各种数据流 stream 类定义。。。




### uart_esc start -D /dev/tty-2
int uart_esc_main(int argc, char *argv[])  # W:\uav\Firmware\src\drivers\px4_legacy_driver_wrapper\uart_esc\uart_esc_main.cpp
```bash
    uart_esc::start()->task_main(int argc, char *argv[])
        parameters_init(); # 电调参数初始化
        esc = UartEsc::get_instance()  # 获取电调实例， 实现在libuart.so
  	orb_subscribe(ORB_ID(actuator_controls_0));  # 订阅主题
	orb_subscribe(ORB_ID(actuator_armed));
	orb_subscribe(ORB_ID(parameter_update));
        initialize_mixer(MIXER_FILENAME) # 设置mixer
        while( )
            orb_copy(ORB_ID(actuator_controls_0), _controls_sub, &_controls)
            esc->send_rpms(motor_rpms, _outputs.noutputs)    
```

### attitude_estimator_q start     （主要接收sensor和vehicle_global_position主题，处理， 发布飞行姿态主题）
W:\uav\Firmware\src\modules\attitude_estimator_q\attitude_estimator_q_main.cpp
```bash
int attitude_estimator_q_main(int argc, char *argv[])
    attitude_estimator_q::instance = new AttitudeEstimatorQ
    AttitudeEstimatorQ::start() 
        AttitudeEstimatorQ::task_main() 

            orb_subscribe(ORB_ID(sensor_combined))
            orb_subscribe(ORB_ID(parameter_update))
            orb_subscribe(ORB_ID(vehicle_global_position))

            update_parameters(true)
            --> AttitudeEstimatorQ::update_parameters(bool force)
                orb_copy(ORB_ID(parameter_update), _params_sub, &param_update)
                param_get(_params_handles.w_acc, &_w_accel)
                ...

            while (!_task_should_exit)
                px4_poll(fds, 1, 1000)      # fds[0].fd = _sensors_sub , 监控订阅的sensors数据
                orb_copy(ORB_ID(sensor_combined), _sensors_sub, &sensors)    # 获取订阅的sensors数据
                orb_check(_global_pos_sub, &gpos_updated)    # 功能类似于px4_poll()
                orb_copy(ORB_ID(vehicle_global_position), _global_pos_sub, &_gpos)

                struct vehicle_attitude_s att    # 创建飞行姿态结构并赋值
                att_pub = orb_advertise(ORB_ID(vehicle_attitude), &att)   # 公布飞行姿态主题
                orb_publish(ORB_ID(vehicle_attitude), _att_pub, &att)     # 发布飞行姿态主题
```

### position_estimator_inav start （订阅飞控等相关主题，接收到主题后，进行一些算法处理。 发布vehicle_local_position、vehicle_global_position主题）
 W:\uav\Firmware\src\modules\position_estimator_inav\position_estimator_inav_main.c
```bash
int position_estimator_inav_thread_main(int argc, char *argv[])
    # declare and safely initialize all structs
    struct actuator_controls_s actuator
    struct actuator_armed_s armed
    struct sensor_combined_s sensor
    struct vehicle_gps_position_s gps
    struct home_position_s home
    struct vehicle_attitude_s att
    struct vehicle_local_position_s local_pos
    struct optical_flow_s flow
    struct vision_position_estimate_s vision
    struct att_pos_mocap_s mocap
    struct vehicle_global_position_s global_pos

    # 订阅相关主题
    orb_subscribe(ORB_ID(parameter_update));
    orb_subscribe(ORB_ID_VEHICLE_ATTITUDE_CONTROLS);
    orb_subscribe(ORB_ID(actuator_armed));    orb_subscribe(ORB_ID(sensor_combined));    orb_subscribe(ORB_ID(vehicle_attitude));    orb_subscribe(ORB_ID(optical_flow));
    orb_subscribe(ORB_ID(vehicle_gps_position));    orb_subscribe(ORB_ID(vision_position_estimate));    orb_subscribe(ORB_ID(att_pos_mocap));
    orb_subscribe(ORB_ID(home_position));

    orb_advertise(ORB_ID(vehicle_local_position), &local_pos)  # 公布vehicle_local_position主题
    inav_parameters_update(&pos_inav_param_handles, &params) # 获取所有相关参数

    while (wait_baro && !thread_should_exit)
        px4_poll(fds_init, 1, 1000)               # 监控sensor_combined主题
        orb_copy(ORB_ID(sensor_combined), sensor_combined_sub, &sensor)    # 获取sensors数据

    while (!thread_should_exit)
        px4_poll(fds, 1, 20)             # 监控vehicle_attitude主题
        orb_copy(ORB_ID(vehicle_attitude), vehicle_attitude_sub, &att)     # 获取飞行姿态数据
        orb_copy(ORB_ID(parameter_update), parameter_update_sub, &update)
        inav_parameters_update(&pos_inav_param_handles, &params)
        orb_copy(ORB_ID_VEHICLE_ATTITUDE_CONTROLS, actuator_sub, &actuator)  # 获取actuator数据
        orb_copy(ORB_ID(actuator_armed), armed_sub, &armed)    # 获取armed数据   
        orb_copy(ORB_ID(sensor_combined), sensor_combined_sub, &sensor) #  获取sensors数据
        acc[i] += PX4_R(att.R, i, j) * sensor.accelerometer_m_s2[j]  # transform acceleration vector from body frame to NED frame
        orb_copy(ORB_ID(optical_flow), optical_flow_sub, &flow)  # 获取光流数据        ...        orb_copy(ORB_ID(home_position), home_position_sub, &home)   # 获取home position数据        orb_copy(ORB_ID(vision_position_estimate), vision_position_estimate_sub, &vision)  # 获取vehicle vision position数据        orb_copy(ORB_ID(att_pos_mocap), att_pos_mocap_sub, &mocap)  #  获取 vehicle mocap position数据
        orb_copy(ORB_ID(vehicle_gps_position), vehicle_gps_position_sub, &gps)  # 获取vehicle GPS position 数据

        orb_publish(ORB_ID(vehicle_local_position), vehicle_local_position_pub, &local_pos)   # publish local position        orb_advertise(ORB_ID(vehicle_global_position), &global_pos)        orb_publish(ORB_ID(vehicle_global_position), vehicle_global_position_pub, &global_pos) 
```


### mc_att_control  start
 W:\uav\Firmware\src\modules\mc_att_control\mc_att_control_main.cpp
```bash
int mc_att_control_main(int argc, char *argv[])
    mc_att_control::g_control = new MulticopterAttitudeControl
    MulticopterAttitudeControl::start()
        MulticopterAttitudeControl::task_main()
	    orb_subscribe(ORB_ID(vehicle_attitude_setpoint));	    orb_subscribe(ORB_ID(vehicle_rates_setpoint));	    orb_subscribe(ORB_ID(vehicle_attitude));	    orb_subscribe(ORB_ID(vehicle_control_mode));	    orb_subscribe(ORB_ID(parameter_update));	    orb_subscribe(ORB_ID(manual_control_setpoint));	    orb_subscribe(ORB_ID(actuator_armed));	    orb_subscribe(ORB_ID(vehicle_status));
	    orb_subscribe(ORB_ID(multirotor_motor_limits));

            orb_copy(ORB_ID(vehicle_attitude), _v_att_sub, &_v_att)  #  获取飞行姿态主题
            if (_v_control_mode.flag_control_attitude_enabled)
                orb_publish(_rates_sp_id, _v_rates_sp_pub, &_v_rates_sp) #  publish attitude rates setpoint
            else { if (_v_control_mode.flag_control_manual_enabled)
                orb_publish(_rates_sp_id, _v_rates_sp_pub, &_v_rates_sp)
            orb_publish(_actuators_id, _actuators_0_pub, &_actuators)
            orb_publish(ORB_ID(mc_att_ctrl_status),_controller_status_pub, &_controller_status)
```


### mc_pos_control start
 W:\uav\Firmware\src\modules\mc_pos_control\mc_pos_control_main.cpp
```bash
int mc_pos_control_main(int argc, char *argv[])
    pos_control::g_control = new MulticopterPositionControl;
    MulticopterPositionControl::start()
        MulticopterPositionControl::task_main()
	    orb_subscribe(ORB_ID(vehicle_status));
	    orb_subscribe(ORB_ID(vehicle_attitude));
	    orb_subscribe(ORB_ID(vehicle_attitude_setpoint));
	    orb_subscribe(ORB_ID(vehicle_control_mode));
	    orb_subscribe(ORB_ID(parameter_update));
	    orb_subscribe(ORB_ID(manual_control_setpoint));
	    orb_subscribe(ORB_ID(actuator_armed));
	    orb_subscribe(ORB_ID(vehicle_local_position));
	    orb_subscribe(ORB_ID(position_setpoint_triplet));
	    orb_subscribe(ORB_ID(vehicle_local_position_setpoint));
	    orb_subscribe(ORB_ID(vehicle_global_velocity_setpoint));

            poll_subscriptions()  # check & copy所有传感器数据， 初始化更新
            --> MulticopterPositionControl::poll_subscriptions()
            while (）
                px4_poll(&fds[0], (sizeof(fds) / sizeof(fds[0])), 500)   # 监控vehicle_local_position主题
                poll_subscriptions()   #  check相关数据，if update， 获取数据
                update_ref()   #  position setpoint
                # select control source
                control_manual(dt)
                control_offboard(dt)
                control_auto(dt)
                if (!_control_mode.flag_control_manual_enabled &&...)
                    orb_publish(ORB_ID(vehicle_attitude_setpoint), _att_sp_pub, &_att_sp) # 发布vehicle_attitude_setpoint主题
                else
                    orb_publish(ORB_ID(vehicle_global_velocity_setpoint), _global_vel_sp_pub, &_global_vel_sp)  # 发布 velocity setpoint主题
                orb_publish(ORB_ID(vehicle_local_position_setpoint), _local_pos_sp_pub, &_local_pos_sp)   # 发布vehicle_local_position_setpoint主题
                generate attitude setpoint from manual controls
                /* publish attitude setpoint
		 * Do not publish if offboard is enabled but position/velocity control is disabled,
		 * in this case the attitude setpoint is published by the mavlink app
		 */
                orb_publish(ORB_ID(vehicle_attitude_setpoint), _att_sp_pub, &_att_sp)  # 发布vehicle_attitude_setpoint主题
```
