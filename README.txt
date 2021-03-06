使用perl语言编写的QQ机器人(采用webqq协议)
核心依赖模块:
    JSON
    Digest::MD5
    AnyEvent::UserAgent
    LWP::UserAgent
    LWP::Protocol::https
    IPC::Run

客户端异步框架:
client 
 | 
 ->login()
    |
    |->timer(60s)->_get_msg_tip()#heartbeat 
    |        +-------------------------<------------------------------+
    |        |                                                        |
    |->_recv_message()-[put]-> Webqq::Message::Queue -[get]-> on_receive_message()
    |
    |->send_message() -[put]--+                       +-[get]-> _send_message() ---+
    |                           \                   /                              +
    |->send_sess_message()-[put]-Webqq::Message::Queue-[get]->_send_sess_message()-+               
    |                              /              \                                +
    |->send_group_message()-[put]-+                +-[get]->_send_group_message()--+
    |                                                                              +
    |                          on_send_message() ---<---- msg->{cb} -------<-------+
    +->run()

版本更新记录:
2014-11-07 Webqq::Client v2.9
1）修复收到下线通知消息时客户端处理错误，感谢[perl技术 @路人丙]的测试反馈
2）增加Webqq::Client::App::ShowMsg应用，可以方便打印收到的消息

2014-11-07 Webqq::Client v2.8
1）Webqq::Client::App::Perlcode支持自动查找本机perldoc路径
2）Webqq::Client::App::Perldoc支持自动查找本机perl路径
3）Webqq::Client::App::Perldoc/Webqq::Client::App::Perlcode运行在非linux系统报错退出

2014-11-03 Webqq::Client v2.7
1）新增Webqq::Client::Cron模块，支持定时执行回调
2）新增Webqq::Client::App::Msgstat应用，统计群内成员发送消息数量

2014-11-03 Webqq::Client v2.6
1）支持从本地socket接收发送消息指令
2）支持从QQ消息接收发送消息指令

2014-10-31 Webqq::Client v2.5
1）使用深拷贝彻底修复重新登录异常问题 

2014-10-29 Webqq::Client v2.4
1）修复重新登录异常问题

2014-10-27 Webqq::Client v2.3
1）增加登录成功、输入验证码回调函数
2）支持在未连接TTY时将验证码通过邮件形式发送到指定邮箱，
   可以在邮箱中点击链接直接完成验证码输入（方便在手机上随时收邮件输验证码）
   通过这种方式可以避免QQ每隔一段时间被强迫下线无法在电脑前再次输入验证码的缺点

2014-10-23 Webqq::Client v2.2
1）修复因临时目录不存在出现chroot失败，导致有权限执行危险系统命令
2）其他少量细节完善

2014-09-28 Webqq::Client v2.1
1）增加定时更新群列表信息，群信息
2）群信息查询结果进行缓存
3）数据查询和数据更新进行了分离
4）消息发送添加发送间隔，腾讯webqq不允许短时间内发送次数过于频繁

2014-09-28 Webqq::Client v2.0
1）支持获取临时消息联系人信息
2）$msg消息结构采用AAG(Automated Accessor Generation)技术，
   每个hash的key都自动产生一个对应的的方法，
   即，你可以使用$msg->{key}或者$msg->key任意一种方式获取你想要的数据
   如感兴趣，可以参见cpan Class::Accessor模块
3）修复更新导致无法正常发送消息问题

2014-09-27 Webqq::Client v1.9
1）修复获取好友信息列表时，如果设置了好友备注名称会导致程序抛出异常的bug
   感谢来自[perl技术 @阳]的反馈
2）完善了一些感谢人员信息

2014-09-26 Webqq::Client v1.8
1）增加->relogin()方法，在系统提示需要重新登录时尝试自动重新登录或者重新连接
2）修复客户端login_state设置bug
3）修复perlcode可以写入和读取系统文件问题

2014-09-26 Webqq::Client v1.7
1）支持接收和回复群临时消息(sess_message)
2）由于机器人大部分情况下都是根据接收的消息进行回复，因此增加reply_message()
   使得消息处理，更加便捷，传统的方式，你需要自己create_msg，再send_message
   这种方式更适合主动发送消息，采用reply_message($msg,$content)
   只需要传入接收消息结构和要发送的内容，即可回复消息，且不需要关心消息的具体类型
3）根据聊天信息中的perldoc和perlcode指令进行文档查询和执行perl代码，源码公布
   有兴趣可以参考:
       Webqq::Client::App::Perldoc
       Webqq::Client::App::Perlcode
   后续会考虑形成中间件的开发框架，让更多的人参与,开发更多有趣的中间件

2014-09-18 Webqq::Client v1.6
1）修改发送消息数据编码，提高发送消息可靠些

2014-09-18 Webqq::Client v1.5
1）增加心跳检测
2）发送群消息增加一个Origin的HTTP请求头希望可以解决群消息偶尔发送不成功问题

2014-09-17 Webqq::Client v1.4
1）修复图片和表情无法正常显示问题，现在图片和表情会被转为文本形式 [图片][系统表情]
2）改进发送群消息机制，通过群消息group_code对应的gid再进行群消息发送
3）增加Webqq::Client::Cache模块，用于缓存一些经常需要使用的信息，避免时时查询
4）增加获取个人信息、好友信息、群信息、群成员信息功能
5）增加查询好友QQ号码功能
6）增加注销功能，程序运行后使用CTRL+C退出时，会自动完成注销
7）增加对强迫下线消息的处理
----
当前发现的一些BUG：
1）再一次消息接收中如果包含多个消息，可能会导致只处理第一个消息，其他消息丢失
2）偶尔会出现发送群消息提示成功，但对方无法接收到的问题（可能和JSON编码有关）

2014-09-14 Webqq::Client v1.3
1）添加一些代码注释
2）demo/*.pl示例代码为防止打印乱码，添加终端编码自适应
3）添加Webqq::Message::Queue消息队列，实现接收消息、处理消息、发送消息等函数解耦

2014-09-14 Webqq::Client v1.2
1）源码改为UTF8编写，git commit亦采用UTF8字符集，以兼容github显示
2）优化JSON数据和perl内部数据格式之间转换，更好的兼容中文
3）修复debug下的打印错误（感谢 [PERL学习交流 @卖茶叶perl高手] 的bug反馈）
4）新增demo/console_message.pl示例代码，把接收到的普通消息和群消息打印到终端

2014-09-12 Webqq::Client v1.1
1）debug模式下支持打印send_message，send_group_message的POST提交数据，方便调试
2）修复了无法正常发送中文问题
3）修复了无法正常发送包含换行符的内容
4) on_receive_message/on_send_message改为是lvalue方法，以支持getter和setter方式

