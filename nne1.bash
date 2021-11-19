#  E01
#  2つのネットワークネームスペースns1とns2を作成する(仮想PC)。ns1とns2に仮想イーサ
#  ネットインタフェースとIPアドレスを追加して、pingコマンドでネットワークの疎通を
#  確認する。ns1とns2は同一セグメントに所属している。セグメントとはLANのことである。
#  同一セグメント内に所属するPC同士はルーターが無くても互いに通信することが可能で
#  ある。逆に同一セグメントに所属しない場合はルーターが無いと通信することができない。

#状態(status): 
# 0:初期状態
# 1:ネットワークネームスペースns1,ns2を作成した状態
# 2:仮想ネットワークインタフェースns1-veth0,ns2-veth0を作成した状態
# 3:仮想ネットワークインタフェースをns1,ns2に配置した状態
# 4:仮想ネットワークインタフェースにIPアドレスを設定した状態
# 5:仮想ネットワークインタフェースを有効にした状態
stat=0	


function fn_fig1() {
cat << END
#                        
#     +----------------+    
#     |                |    
# ns1 |                |
#     |                |
#     +----------------+    
#                           
#     +----------------+    
#     |                |    
# ns2 |                |    
#     |                |    
#     +----------------+    
#

END
}

function fn_exp1() {
cat << END
# ネットワークネームスペースを2つ作成します。ns1とns2はホストOSのLinuxからはネット
# ワーク的に独立しています。ここではns1とns2を仮想PCとして扱います。
# 
# sudo ip netns add ns1
# sudo ip netns add ns2
#
# 「sudo 管理者コマンド」は、管理者権限が無いと実行できないコマンドを特別に許可さ
#  れたユーザーが実行できるようにするためのコマンドです。ipコマンドの一部の機能を
#  実行するには管理者権限が必要です。
#
# 「ip netns」コマンドはネットワークネームスペース関連の設定をするコマンドです。
# 「ip netns add ネットワークネームスペース名」は、ネットワークネームスペースを
#  作成します。作成したネットワークネームスペースは「ip netns list」コマンドで
#  確認できます(メニュー 6.ネットワークネームスペースを確認)。

END
}

function fn_fig2() {
cat << END
#
#     +----------------+    
#     |                |   
# ns1 |                |    o ns1-veth0  
#     |                |    |
#     +----------------+    |
#                           |
#     +----------------+    |
#     |                |    |
# ns2 |                |    o ns2-veth0  
#     |                |    
#     +----------------+    
#

END
}

function fn_exp2() {
cat << END
# 仮想ネットワークインタフェース(NIC)を作成します。ns1-veth0とns2-veth0が仮想
# ネットワークインタフェースです。イメージとしては両端に仮想NICが接続された
# ネットワークケーブルを作成した状態です。ここでは仮想ネットワークインタフェース
# はまだネットワークネームスペースに配置されていません。
#
# ip link add ns1-veth0 type veth peer name ns2-veth0
#
# 「ip link」コマンドは、ネットワークインタフェース関連の設定をするコマンドです。
#   add NIC名       :仮想ネットワークインタフェース名を追加します。
#   type タイプ     :タイプのvethは仮想イーサネット(virtual ethernet)を指定します。
#   peer name NIC名 :ペアとなる仮想ネットワークインタフェース名を指定します。

END
}

function fn_fig3() {
cat << END
#
#     +----------------+    
#     |        DOWN    |    
# ns1 |      ns1-veth0 o----+
#     |                |    |
#     +----------------+    |
#                           |
#     +----------------+    |
#     |        DOWN    |    |
# ns2 |      ns2-veth0 o----+
#     |                |  
#     +----------------+   
#

END
}

function fn_exp3() {
cat << END
# 仮想ネットワークインタフェースをネットワークネームスペースに配置します。
# これで仮想ネットワーク上においてns1とns2がケーブルで接続されました。
# しかし、まだ仮想ネットワークインタフェースは無効(DOWN)な状態です。
# よってまだ通信はできません。
#
# sudo ip link set ns1-veth0 netns ns1
# sudo ip link set ns2-veth0 netns ns2
#
# 「ip link set 仮想NIC名 netns ネットワークネームスペース名 」コマンドは、
# は仮想ネットワークインタフェースをネットワークネームスペースに配置します。 

END
}

function fn_fig4() {
cat << END
#
#                        [192.0.2.0/24]
#     +----------------+    |
#     |        DOWN    |    |
# ns1 |      ns1-veth0 O----+
#     |   192.0.2.1/24 |    |
#     +----------------+    |
#                           |
#     +----------------+    |
#     |        DOWN    |    |
# ns2 |      ns2-veth0 O----+
#     |   192.0.2.2/24 |    |
#     +----------------+    |
#

END
}

function fn_exp4() {
cat << END
# 仮想ネットワークインタフェースにIPアドレスを設定する。
#
# sudo ip netns exec ns1 ip address add 192.0.2.1/24 dev ns1-veth0
# sudo ip netns exec ns2 ip address add 192.0.2.2/24 dev ns2-veth0
#
# 「ip netns exec」コマンドはネットワークネームスペース内でコマンドを実行する
# ためのコマンドです。ns1とns2はネットワーク的に独立しているために、ns1内に
# あるns1-veth0にIPアドレスを設定するためには、ns1の内部で ip addressコマンド
# を実行する必要があります。
# 「ip address」コマンドはIPアドレスを表示したり、IPアドレスを設定したりします。
# 「ip address add IPアドレス dev ネットワークインタフェース」は、IPアドレスを
# ネットワークインタフェースに設定します。 
# まだ仮想ネットワークインタフェースは無効(DOWN)な状態です。
# 

END
}

function fn_fig5() {
cat << END
#
#                        [192.0.2.0/24]
#     +----------------+    |
#     |         UP     |    |
# ns1 |      ns1-veth0 O----+
#     |   192.0.2.1/24 |    |
#     +----------------+    |
#                           |
#     +----------------+    |
#     |         UP     |    |
# ns2 |      ns2-veth0 O----+
#     |   192.0.2.2/24 |    |
#     +----------------+    |
#

END
}

function fn_exp5() {
cat << END
# 仮想ネットワークインタフェースを有効化(UP)します。
#
# sudo ip netns exec ns1 ip link set ns1-veth0 up
# sudo ip netns exec ns2 ip link set ns2-veth0 up
#
# 「ip link set <device> up」コマンドはネットワークインタフェースを有効化 
# (UP)します。
#

END
}

function fn_fig() {
    echo ''
	case $stat in
	0) echo 'ネットワークネームスペースがありません' ;;
		1) echo '状態(1)'
           fn_fig1 
           ;;
		2) echo '状態(2)'
           fn_fig2
           ;;
		3) echo '状態(3)'
           fn_fig3
           ;;
		4) echo '状態(4)'
           fn_fig4
           ;;
		5) echo '状態(5)'
           fn_fig5
           ;;
	esac
}

function fn_hitAnyKey(){
	echo "> hit any key!"
	read keyin
}

function fn_menu() {
echo '===メニュー===================================='
PS3='番号を入力>'

menu_list='
ネットワークネームスペースを作成
仮想ネットワークインタフェースを作成
仮想ネットワークインタフェースを配置
仮想ネットワークインタフェースにIPアドレスを設定
仮想ネットワークインタフェースを有効化
ネットワークネームスペースを確認
仮想インタフェースを確認
pingを実行
状態を表示
ネットワークネームスペースをすべて削除
終了
課題提出用の出力'

select item in $menu_list
do
	echo ""
	echo "${REPLY}) ${item}します"
	case $REPLY in
	1) #ネットワークネームスペースを作成する
		echo sudo ip netns add ns1
		echo sudo ip netns add ns2
        echo ''
		sudo ip netns add ns1
		sudo ip netns add ns2
		stat=1
		echo $stat > ./.namespace_tmp
		fn_fig
        fn_exp1
		;;
	2) #仮想ネットワークインタフェースを作成する
		echo sudo ip link add ns1-veth0 type veth peer name ns2-veth0
        echo ''
		sudo ip link add ns1-veth0 type veth peer name ns2-veth0
		stat=2
		echo $stat > ./.namespace_tmp
		fn_fig
        fn_exp2
		;;
	3) #仮想ネットワークインタフェースを配置する
		echo  sudo ip link set ns1-veth0 netns ns1
		echo  sudo ip link set ns2-veth0 netns ns2
        echo ''
		sudo ip link set ns1-veth0 netns ns1
		sudo ip link set ns2-veth0 netns ns2
		stat=3
		echo $stat > ./.namespace_tmp
		fn_fig
        fn_exp3
		;;
	4) #仮想ネットワークインタフェースにIPアドレスを設定する
		echo sudo ip netns exec ns1 ip address add 192.0.2.1/24 dev ns1-veth0
		echo sudo ip netns exec ns2 ip address add 192.0.2.2/24 dev ns2-veth0
        echo ''
		sudo ip netns exec ns1 ip address add 192.0.2.1/24 dev ns1-veth0
		sudo ip netns exec ns2 ip address add 192.0.2.2/24 dev ns2-veth0
		stat=4
		echo $stat > ./.namespace_tmp
		fn_fig
        fn_exp4
		;;
	5) #仮想ネットワークインタフェースを有効にする
		echo sudo ip netns exec ns1 ip link set ns1-veth0 up
		echo sudo ip netns exec ns2 ip link set ns2-veth0 up
        echo ''
		sudo ip netns exec ns1 ip link set ns1-veth0 up
		sudo ip netns exec ns2 ip link set ns2-veth0 up
		stat=5
		echo $stat > ./.namespace_tmp
		fn_fig
        fn_exp5
		;;
	6) #ネットワークネームスペースを確認する
		echo ip netns list
        echo ''
		ip netns list
		;;
	7) #仮想ネットワークインタフェースを確認する
		echo sudo ip netns exec ns1 ip link list
        echo ''
		sudo ip netns exec ns1 ip link list
        echo '----------------------------------------------------'
        echo ''
		echo sudo ip netns exec ns2 ip link list
        echo ''
		sudo ip netns exec ns2 ip link list
		;;
	8) #pingを実行(n1->n2)する
		echo 'ns1 から ns2 へpingを実行'
		echo sudo ip netns exec ns1 ping -c 5 192.0.2.2 -I ns1-veth0
        echo ''
		sudo ip netns exec ns1 ping -c 5 192.0.2.2 -I ns1-veth0
		sleep 2

	   #pingを実行(n2->n1)する
		echo ''
		echo '----------------------------------------------------'
		echo 'ns2 から ns1 へpingを実行'
		echo sudo ip netns exec ns2 ping -c 5 192.0.2.1 -I ns2-veth0
        echo ''
		sudo ip netns exec ns2 ping -c 5 192.0.2.1 -I ns2-veth0
		;;
	9) #状態を表示する
		if [  -e ./.namespace_tmp ]
		then
			stat=$(cat ./.namespace_tmp)
		fi
		fn_fig
		;;
	10) #ネットワークネームスペースをすべて削除する
		echo sudo ip -all netns delete
        echo ''
		sudo ip -all netns delete
		stat=0
		rm ./.namespace_tmp
		;;
	11) #終了する
		echo "bye bye!"
		exit
		;;
        12) #課題提出用の出力
            export TZ='Asia/Tokyo'
            read -p '学生番号> ' unumber
            read -p '氏  名  > ' uname
	    echo '----ここから----'
            echo 'NO. : ' $unumber
            echo 'NAME: ' $uname
	    echo 'ID. : ' $(echo $unumber | md5sum)
            echo ''
            date
            fn_fig

            #pingを実行(n1->n2)する
            echo ''
            echo 'ns1 から ns2 へpingを実行'
            echo ''
            sudo ip netns exec ns1 ping -c 5 192.0.2.2 -I ns1-veth0

            #pingを実行(n2->n1)する
            echo ''
            echo 'ns2 から ns1 へpingを実行'
            echo ''
            sudo ip netns exec ns2 ping -c 5 192.0.2.1 -I ns2-veth0
            echo '----ここまで----'
            ;;		
	*)
		echo "番号を入力してください"
	esac

	echo ""
	echo "Enterキーを押してください。"
    read n

	#sleep 2
	fn_menu
done

}

#### START BASH SCRIPT #########################################################

echo '###'
echo '### Network Name Spaceを使った仮想ネットワークの作成'
echo '###'

echo ''
echo 'これから作成するネットワーク'
fn_fig5
sleep 3

echo ""
echo "Enterキーを押してください。"
read n

fn_menu
fn_hitAnyKey


# vim: number tabstop=4 softtabstop=4 shiftwidth=4 textwidth=0 filetype=text:
