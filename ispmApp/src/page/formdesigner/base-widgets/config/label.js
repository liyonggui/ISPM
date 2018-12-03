/**
 * 文本标签配置
 */
export default {
    // 类型
    type: 'label',
    icon: 'ios-information',
    category: 'base-widgets',
    label: '文本标签',
    title: '文本标签',
    // 样式
    style: {
        'text-align': 'left',
        'font-size': 12,
        'color': '#000',
        'font-weight': false,
        'font-family': 'sans-serif'
    },
    // 是否可见
    visibility: true,
    // 是否显示行内元素
    inline: false,
    // 宽度(inline为true时才有效)
    width: '33%',
    // 边距(inline为true时才有效)
    margin: {
        left: '0px',
        right: '0px',
        top: '0px',
        bottom: '0px'
    },
    // 是否可复制
    copy: true,
    // 是否可配置
    config: true
};
