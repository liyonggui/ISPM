/**
 * 单选框配置
 */
export default {
    // 类型
    type: 'radio',
    icon: 'ios-radio-button-on',
    category: 'base-widgets',
    label: '单选框',
    title: '单选框',
    // 后端使用字段，用于判断数据库字段类型
    dbType: 'varchar',
    // TODO: name生成方式？？
    name: '',
    value: '',
    // 选项（select、radio、checkbox）
    // 由于都是选择字典，所以命名就统一用dict了
    dict: {
        type: '',
        options: [{
            label: '请配置数据字典',
            value: ''
        }]
    },
    // 校验
    rules: {
        require: true,
        message: '必填',
        trigger: 'change'
    },
    // 针对select、radio、checkbox、switch可设置关联字段，满足某值时关联字段展示
    // TODO: 编辑页不可见如何处理？直接隐藏之后如何再编辑？具体配置功能待实现
    relation: {
        name: '',
        value: '',
        toggle: false
    },
    // 是否可见(TODO: 编辑页不可见如何处理？直接隐藏之后如何再编辑？)
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
