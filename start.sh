export PATH=~/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/sbin:/bin
Red_font_prefix="\033[31m"
Green_font_prefix="\033[32m"
Font_color_suffix="\033[0m"
Error="[${Red_font_prefix}错误${Font_color_suffix}]"

check_root() {
    [[ $EUID != 0 ]] && echo -e "${Error} 当前非ROOT账号(或没有ROOT权限)，无法继续操作，请更换ROOT账号或使用 ${Green_background_prefix}sudo su${Font_color_suffix} 命令获取临时ROOT权限（执行后可能会提示输入当前账号的密码）。" && exit 1
}
check_qqbot_pid() {
    PID_qqbot=$(ps aux | grep './go-cqhhtp' | grep -v grep | awk '{print $2}')
}

check_wechatbot_pid() {
    PID_wechatbot=$(ps -ef | grep 'run go ./main.go' | grep -v grep | awk '{print $2}')
}

pause()
{
  # 启用功能的开关 1开启|其它不开启
  enable_pause=1

  # 判断第一个参数是否为空，约定俗成的写法
  if [ "x$1" != "x" ]; then
    echo $1
  fi
  if [ $enable_pause -eq 1 ]; then

    echo "提示运行成功后，按住ctrl+c退出，然后重新进入脚本启动服务即可（按任意键继续）"
    char=`get_char`
  fi
}

Qqbot() {
  echo -e "
 ${Green_font_prefix}1.${Font_color_suffix} 部署QQGPTBot
 ${Green_font_prefix}2.${Font_color_suffix} 启动QQGPTBot
 ${Green_font_prefix}3.${Font_color_suffix} 停止QQGPTBot
 ${Green_font_prefix}4.${Font_color_suffix} 修改配置信息
 ———————————————————————" && echo
check_qqbot_pid
if [[ ! -z "${PID_qqbot}" ]]; then
    echo -e " QQGPTBot 状态: ${Green_font_prefix}已启动${Font_color_suffix}"
else
    echo -e " QQGPTBot 状态: ${Red_font_prefix}未启动${Font_color_suffix}"
fi
echo

read -e -p " 请输入数字 [0-5]:" qq_bot_choos
    if [[ ${qq_bot_choos} == "1" ]]; then
        Install_qq_bot
    elif [[ ${qq_bot_choos} == "2" ]]; then
        Star_qq_bot
    elif [[ ${qq_bot_choos} == "3" ]]; then
        Stop_qq_bot
    elif [[ ${qq_bot_choos} == "4" ]]; then
        Modify_qq_bot
    else
        echo
        echo -e " ${Error} 请输入正确的数字"
        exit 1
    fi
}

Wechatbot() {
  echo -e "
 ${Green_font_prefix}1.${Font_color_suffix} 部署WechatGPTBot
 ${Green_font_prefix}2.${Font_color_suffix} 启动WechatGPTBot
 ${Green_font_prefix}3.${Font_color_suffix} 停止WechatGPTBot
 ${Green_font_prefix}4.${Font_color_suffix} 修改配置信息
 ———————————————————————" && echo
check_pid

if [[ ! -z "${PID_wechatbot}" ]]; then
    echo -e " WechatGPTBot 状态: ${Green_font_prefix}已启动${Font_color_suffix}"
else
    echo -e " WechatGPTBot 状态: ${Red_font_prefix}未启动${Font_color_suffix}"
fi

echo
read -e -p " 请输入数字 [0-4]:" qq_bot_choos
    if [[ ${wechat_bot_choos} == "1" ]]; then
        Install_wechat_bot
    elif [[ ${wechat_bot_choos} == "2" ]]; then
        Star_wechat_bot
    elif [[ ${wechat_bot_choos} == "3" ]]; then
        Stop_wechat_bot
    elif [[ ${wechat_bot_choos} == "4" ]]; then
        Modify_wechat_bot
    else
        echo
        echo -e " ${Error} 请输入正确的数字"
        exit 1
    fi
}

Install_qq_bot(){
  check_root
  apt -y update
  apt install -y coreutils
  apt install -y python3.8
  python3.8 -m pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple
  python3.8  -m pip install Flask==2.2.2 -i https://pypi.tuna.tsinghua.edu.cn/simple
  python3.8  -m pip install openai==0.25.0 -i https://pypi.tuna.tsinghua.edu.cn/simple
  cd ./qqbot
  read -e -p " 请输入qq号：" qq_code
  sed -i "4s#qqcode#${qq_code}#g" config.yml
  read -e -p " 请输入qq密码：" qq_passwd
  sed -i "5s#qqpasswd#${qq_passwd}#g" config.yml
  read -e -p " 请输入openai_api_key：" qq_openai_key
  sed -i "5s#apiKey#${qq_openai_key}#g" ./app/config.json
  python3.8 ./app/main.py
  clear
  pause
  chmod +x ./go-cqhttp
  ./go-cqhttp -faststart
  exit 0
}

Star_qq_bot(){
  cd ./qqbot
  nohub python3.8 ./app/main.py >/dev/null 2>1 &
  nohup ./go-cqhhtp >/dev/null 2>1 &
  echo -e "启动成功"
  exit 0
}

Stop_qq_bot(){
  kill -9 $(ps aux | grep 'python3.8 ./app/main.py' | grep -v grep | awk '{print $2}')
  kill -9 $(ps aux | grep './go-cqhhtp' | grep -v grep | awk '{print $2}')
  echo -e "停止成功"
  exit 0
}
Modify_qqcoade(){
read -r -p "是否修改qq号? [Y/n] " input_one

case $input_one in
    [yY][eE][sS]|[yY])
		read -e -p " 请输入qq号：" qq_code
    sed -i "4s#qqcode#${qq_code}#g" config.yml
    echo "修改成功"
		;;

    [nN][oO]|[nN])
		return 1
       	;;

    *)
		echo "无效输入"
		exit 1
		;;
esac
}
Modify_qqpasswd(){
  read -r -p "是否修改qq密码? [Y/n] " input_two

case $input_two in
    [yY][eE][sS]|[yY])
    read -e -p " 请输入qq密码：" qq_passwd
    sed -i "5s#qqpasswd#${qq_passwd}#g" config.yml
    echo "修改成功"
		;;

    [nN][oO]|[nN])
		return 1
       	;;

    *)
		echo "无效输入"
		exit 1
		;;
esac
}
Modify_openai_api_key(){
  read -r -p "是否修改openai_api_key? [Y/n] " input_three

case $input_three in
    [yY][eE][sS]|[yY])
    read -e -p " 请输入openai_api_key：" qq_openai_key
    sed -i "5s#apiKey#${qq_openai_key}#g" ./app/config.json
    echo "修改成功"
		;;

    [nN][oO]|[nN])
		return 1
       	;;

    *)
		echo "无效输入"
		exit 1
		;;
esac
}
Modify_qq_bot(){
  cd ./qqbot
  Modify_qqcoade
  Modify_qqpasswd
  nohub python3.8 ./app/main.py >/dev/null 2>1 &
  nohup ./go-cqhhtp >/dev/null 2>1 &
  echo "启动成功"
  exit 0
}

Install_wechat_bot(){
  check_root
  apt update -y
  apt install coreutils
  apt install go
  cd wechatbot
  go env -w GO111MODULE=on
  go env -w GOPROXY=https://goproxy.io,direct
  read -e -p " 请输入openai_api_key：" wechat_openai_key
  sed -i "2s#apiKey#${wechat_openai_key}#g" ./config.json
  clear
  pause
  go run main.go
  exit 0
}

Star_wechat_bot(){
  cd wechatbot
  nohup run ./main.go >/dev/null 2>1 &
  echo -e "启动成功"
  exit 0
}

Stop_wechat_bot(){
  kill -9 $(ps -ef | grep 'run go ./main.go' | grep -v grep | awk '{print $2}')
  echo -e "停止成功"
  exit 0
}

Modify_wechat_bot(){
  cd wechatbot
  read -e -p " 请输入openai_api_key：" wechat_openai_key
  sed -i "2s#apiKey#${wechat_openai_key}#g" ./config.json
  echo -e "修改成功"
  nohup run ./main.go >/dev/null 2>1 &
  echo "启动成功"
  exit 0
}


echo && echo -e " ChatGPTBot 一键部署脚本（按住ctrl+c退出）


 ${Green_font_prefix}1.${Font_color_suffix} QQGPTBot
 ${Green_font_prefix}2.${Font_color_suffix} WeichatGPTBot
"
echo
read -e -p " 请输入数字:" num
case "$num" in
1)
    Qqbot
    ;;
2)
    Qwechatbot
    ;;
*)
    echo
    echo -e " ${Error} 请输入正确的数字"
    ;;
esac

