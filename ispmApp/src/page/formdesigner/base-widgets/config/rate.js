/**
 * 评分配置
 */
export default {
    // 类型
    type: 'rate',
    icon: 'ios-star-outline',
    category: 'base-widgets',
    label: '评分',
    title: '评分',
    // 后端使用字段，用于判断数据库字段类型
    dbType: 'varchar',
    // TODO: name生成方式？？
    name: '',
    value: '',
    count: 5,
    'allow-half': false,
    // 校验
    rules: {
        require: true,
        message: '必填',
        trigger: 'change',
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
