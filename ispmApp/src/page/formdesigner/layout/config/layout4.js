export default {
    // 类型
    type: 'layout',
    category: 'layout',
    title: '四列式',
    // 是否可见
    visibility: true,
    // 是否可复制
    copy: true,
    // 是否可配置
    config: true,
    // 行、列、列宽
    row: 1,
    col: 4,
    span: [6, 6, 6, 6],
    // 边框
    border: {
        top: false,
        right: false,
        bottom: false,
        left: false
    },
    // 组件列表（每列一个数组）
    widgets: [
        [], [], [], []
    ]
};
