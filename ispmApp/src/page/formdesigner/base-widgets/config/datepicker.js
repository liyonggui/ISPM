/**
 * 日期框配置
 */
export default {
    // 类型
    type: 'datepicker',
    icon: 'ios-calendar-outline',
    category: 'base-widgets',
    label: '日期框',
    title: '日期选择框',
    // 后端使用字段，用于判断数据库字段类型
    dbType: 'datetime',
    // TODO: name生成方式？？
    name: '',
    // date、daterange、datetime、datetimerange、year、month
    datetype: 'date',
    placeholder: '',
    value: null,
    // 校验
    rules: {
        require: true,
        message: '必填',
        trigger: 'change',
        type: 'date'
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
