/**
 * 数字输入框配置
 */
export default {
    // 类型
    type: 'numberinput',
    icon: 'ios-create-outline',
    category: 'base-widgets',
    label: '数字输入框',
    title: '数字输入框',
    // 后端使用字段，用于判断数据库字段类型
    dbType: 'decimal',
    // TODO: name生成方式？？
    name: '',
    max: Infinity,
    min: -Infinity,
    decimal: 0,
    value: 0,
    // 校验
    rules: {
        require: true,
        message: '必填',
        trigger: 'blur',
        type: 'number'
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
