#!/bin/bash
#实现拷贝制定路径-s的文件到目标集群-i上的-d路径下，名称为-a jar文件
#然后杀死同名old应用，并启动该应用

###获取参数####
while getopts "i:p:a:d:s:e:" arg
do
        case $arg in
             i) #-i '(0.0.0.1 0.0.0.2)'  目标集群ip数组字符串，采用空格分开
                ips=($OPTARG)
                echo "ips:$ips"
                ;;
             p) #-p '(123 456)' 目标集群密码数组字符串，采用空格分开
                passwd=($OPTARG)
                echo "passwd:$passwd"
                ;;
             a) #-a dish-app  jar包名称
                app_name=$OPTARG
                echo "app_name:$app_name"
                ;;
             d) #-d /root/ 目标集群部署路径
                target_dir=$OPTARG
                echo "target_dir:$target_dir"
                ;;
             s) #-s /home/release/jar/dish.jar 希望部署的jar包路径
                src_app_path=$OPTARG
                echo "src_app_path:$src_app_path"
                ;;
	     e) #-e dev 希望使用jar的某环境的配置文件（dev、test、prod）
                profile=$OPTARG
                echo "profile:$profile"
		;;
        esac
done

###部署到目标集群###
#1.拷贝到目标机器
#2.杀死old应用
#3.启动新的应用
for idx in ${!ips[@]}; do 
    expect -c "
        spawn scp $src_app_path root@${ips[$idx]}:$target_dir/${app_name}
        expect  {
                \"*assword\" {set timeout 300; send \"${passwd[$idx]}\r\";} 
                \"yes/no\" {send \"yes\r\";exp_continue}
        }
        expect eof
    "

    expect -c "
        spawn ssh root@${ips[$idx]}
        expect {
            \"*assword\" {set timeout 300; send \"${passwd[$idx]}\r\";}
            \"yes/no\" {send \"yes\r\"; exp_continue;}
        }
        expect "*#"
        send \"cd '$target_dir'\r\"
        expect "*#"
        send \"ps aux|grep ${app_name}|awk '{print \\\$2}'|xargs kill\r\"
        expect "*#"
        send \"sleep 5\r\"
        expect "*#"
        send \"ps aux|grep ${app_name}|awk '{print \\\$2}'|xargs kill -9\r\"
        expect "*#"
        send \"nohup java -jar $target_dir/${app_name} --spring.profiles.active=${profile}& \r\"
        expect "*#"
        send \"exit \r\"
        expect eof
    "
done
