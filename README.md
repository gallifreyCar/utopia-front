时间有限，最后还在写代码，请先看视频效果：https://www.bilibili.com/video/BV1qz4y1P77w/

项目架构挺有意思的，如果有机会答辩，可以说说

这是大体的文件目录
  - api请求有四层抽象，实现层，mock层和model
  - custom_widgets是自定义的组件
  - global全局配置
  - pages是页面
  - storage是持久层
  - util是自用工具包
```
├─api
│  ├─abstract
│  ├─implement
│  ├─mock
│  └─model
├─custom_widgets
├─global
├─pages
│  ├─login
│  ├─user
│  └─video
├─storage
│  ├─abstract
│  └─implement
└─util
