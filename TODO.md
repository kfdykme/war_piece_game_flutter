- before start [DONE]
    - map 
        - 六边形布局
    - 40 种棋子随机 10 
- ban pick 环节 [DONE]
    - player 1 ban 1
    - player 2 ban 1
    - player 1 pick 1
    - player 2 pick 2
    - player 1 pick 2
    - player 2 pick 2
    - player 1 pick 1
    - 构造棋子信息
- 初始化
    - 每名玩家各自9枚棋子
        - 4 * 2 个棋子
        - 1 皇家硬币
    - 将这9枚硬币混匀
    - 随机抽取3枚硬币
        - 打出硬币
            - 部署
                - 需要找到可以部署的位置
                - 高亮可点击
                - 点击响应
            - 增强
                - 
        - 背面弃置
            - 宣告先手
            - 招募
            - 跳过行动
        - 正面弃置
            - 移动
            - 攻击
            - 控制     
            - 战术  
    - 继续抽取
- 联网
    - 1. EventLoop 机制
    - 2. 本地 OnEvent 的时候同步推送一个event到远端
    - 3. 远端等待用户操作/AI/网络请求产生的event
    - 4. 远端处理Event ，让两个客户端数据一致
    



## 六边形布局

1. 给一个origin 得到周围六节点的xy

(0,0) -> 
()
