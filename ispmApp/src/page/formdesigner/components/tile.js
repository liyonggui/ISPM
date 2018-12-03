/**
 * 磁贴
 * form表单中widget容器
 * 有操作栏（复制、配置、删除）
 */
import tileBar from './tile-bar';
import dateUtil from '../utils/date-util';
import transferUtil from '../utils/transfer-util';

export default {
    name: 'tile',
    render (h) {
        // 工具栏
        const tileToolbar = this.config && this.prop.config ? tileBar(this, h) : [];
        if (['layout1', 'layout2', 'layout3', 'layout4'].indexOf((this.name.toLowerCase())) >= 0) {   // layout
            // 获取当前控件
            let widgetComponent;
            if (this.config) {
                widgetComponent = require(`../${this.prop.category}/${this.prop.type.toLowerCase()}`).default;
            } else {
                widgetComponent = require(`../${this.prop.category}/display/${this.prop.type.toLowerCase()}`).default;
            }
            const currentWidget = (widgetComponent && widgetComponent(this, h)) || [];
            return h(
                "div", {
                    style: {
                        'position': 'relative'
                    },
                    class: {
                        'tile-layout': true
                    }
                },
                currentWidget.concat(tileToolbar)
            );
        } else if (['hr', 'label'].indexOf((this.name.toLowerCase())) >= 0) {  // 不需要formItem
            // 获取当前控件
            const widgetComponent = require(`../${this.prop.category}/${this.prop.type.toLowerCase()}`).default;
            const currentWidget = (widgetComponent && widgetComponent(this, h)) || [];
            return h(
                "div", {
                    style: {
                        'position': 'relative',
                        'font-size': '12px',
                        'line-height': '32px',
                        // 移动端直接无脑瀑布流，block省事；web端为了更灵活，用inline-block，靠宽度控制定位
                        display: this.prop.inline ? 'inline-block' : 'block',
                        // 行内元素width为33%
                        width: this.prop.inline ? (this.prop.width ? this.prop.width : '33%') : 'auto',
                        // 边距margin
                        'margin-left': this.prop.inline ? (this.prop.margin ? (this.prop.margin.left ? this.prop.margin.left : '0px') : '0px') : '0px',
                        'margin-right': this.prop.inline ? (this.prop.margin ? (this.prop.margin.right ? this.prop.margin.right : '0px') : '0px') : '0px',
                        'margin-top': this.prop.inline ? (this.prop.margin ? (this.prop.margin.top ? this.prop.margin.top : '0px') : '0px') : '0px',
                        'margin-bottom': this.prop.inline ? (this.prop.margin ? (this.prop.margin.bottom ? this.prop.margin.bottom : '0px') : '0px') : '0px'
                    },
                    class: {
                        'tile': true
                    }
                },
                currentWidget.concat(tileToolbar)
            );
        } else {    // 需要formItem
            // 获取当前控件
            let currentWidget;
            if (this.disabled && this.prop.type !== 'upload') {    // 只读，附件单独处理
                let displayVal = this.prop.name && this.data[this.prop.name] ? this.data[this.prop.name] : (this.prop.value || '');
                if (displayVal) {
                    if (this.prop.type === 'orgselect') {
                        displayVal = JSON.parse(displayVal).name;
                    } else if (this.prop.type === 'radio' || this.prop.type === 'select' || this.prop.type === 'checkbox') {
                        let values;
                        displayVal.split(',').forEach(val => {
                            if (values) {
                                values += (',' + this.dictTranslate(this.prop.dict.type, val));
                            } else {
                                values = this.dictTranslate(this.prop.dict.type, val);
                            }
                        });
                        displayVal = values;
                    } else if (this.prop.type === 'datepicker' || this.prop.type === 'timepicker') {
                        displayVal = this.dateFormat(new Date(displayVal), this.prop.datetype);
                    } else if (this.prop.type === 'switch') {
                        displayVal = displayVal === '1' ? '开' : '关';
                    } else if (this.prop.type === 'area') {
                        displayVal = this.areaTranslate(displayVal.split(','));
                    }
                }
                let readOnlyDivProp = {
                    domProps: {
                        innerHTML: displayVal,
                        title: displayVal
                    }
                };
                currentWidget = [h('div', readOnlyDivProp)];
            } else {    // 可编辑
                const widgetComponent = require(`../${this.prop.category}/${this.prop.type.toLowerCase()}`).default;
                currentWidget = (widgetComponent && widgetComponent(this, h)) || [];
            }
            // 如果传了默认值，则要回写到组件中
            // 使用this.$set()防止组件属性中没有value属性
            this.$set(this.prop, 'value', this.value ? this.value : this.prop.value);
            // 画formItem
            // 针对web端和app端formItem的属性有差别：是否显示label
            let formItemProp = {
                // 指定验证name
                prop: this.prop.name || 'temp',
                // 验证规则
                rules: this.prop.rules && !this.disabled ? {
                    required: this.prop.rules.require,
                    message: this.prop.rules.message || '必填',
                    trigger: this.prop.rules.trigger,
                    type: this.prop.rules.type || 'string'
                } : {}
            };
            if (this.prop.designType === 'app') {
                formItemProp.label = this.prop.label || this.name;
            }
            const formItem = {
                class: {
                    'tile': true
                },
                props: formItemProp,
                style: {
                    'position': 'relative',
                    // 移动端直接无脑瀑布流，block省事；web端为了更灵活，用inline-block，靠宽度控制定位
                    display: this.prop.inline ? 'inline-block' : 'block',
                    // 行内元素width为33%
                    width: this.prop.inline ? (this.prop.width ? this.prop.width : '33%') : 'auto',
                    // 边距margin
                    'margin-left': this.prop.inline ? (this.prop.margin ? (this.prop.margin.left ? this.prop.margin.left : '0px') : '0px') : '0px',
                    'margin-right': this.prop.inline ? (this.prop.margin ? (this.prop.margin.right ? this.prop.margin.right : '0px') : '0px') : '0px',
                    'margin-top': this.prop.inline ? (this.prop.margin ? (this.prop.margin.top ? this.prop.margin.top : '0px') : '0px') : '0px',
                    'margin-bottom': this.prop.inline ? (this.prop.margin ? (this.prop.margin.bottom ? this.prop.margin.bottom : '0px') : '0px') : '0px'
                }
            };
            return h(
                'div', formItem,
                currentWidget.concat(tileToolbar)
            );
        }
    },
    methods: {
        dateFormat (strDate, datetype) {
            let formatter = transferUtil.getFormmaterByDateType(datetype);
            return dateUtil.format(strDate, formatter);
        },
        dictTranslate (key, val) {
            return this.$translate({key: key, value: val});
        },
        areaTranslate (values) {
            let res = transferUtil.areaTranslate(values, 'name');
            return res.join('/');
        }
    },
    props: {
        // 组件类型
        name: {
            type: String,
            default: 'input'
        },
        // 组件属性
        prop: {
            type: Object,
            default () {
                return {};
            }
        },
        // 组件角标
        index: {
            type: Number,
            default: 0
        },
        // 表单数据
        data: {
            type: Object,
            default () {
                return {};
            }
        },
        // 是否显示工具栏
        config: {
            type: Boolean,
            default: false
        },
        // 是否只读
        disabled: {
            type: Boolean,
            default: false
        },
        // 默认值
        value: [String, Number, Array],
        // 组件列表
        widgetList: {
            type: Array,
            default () {
                return [];
            }
        }
    }
};
