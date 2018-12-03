/**
 * 上传配置
 * TODO: 上传的具体属性配置得之后结合后端考虑
 */
export default {
    // 类型
    type: 'upload',
    icon: 'ios-cloud-upload-outline',
    category: 'base-widgets',
    label: '附件上传',
    title: '附件上传',
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
