/**
 * 日期框组件
 */
import dateUtil from '../utils/date-util';

export default (self, h) => {
    return [
        h('DatePicker', {
            props: {
                placeholder: self.prop.placeholder || '日期框',
                type: self.prop.datetype || 'date',
                value: self.prop.name && self.data[self.prop.name] ? new Date(self.data[self.prop.name]) : (self.prop.value ? new Date(self.prop.value) : null)
            },
            on: {
                'on-change': (value) => {
                    if (!self.prop.name) {
                        return false;
                    }
                    // 官方文档中说使用v-model时，value是Date类型
                    // 而onchange事件中的value是已经格式化的日期，是String类型的。。。
                    // 只好把value根据格式转成Date类型，方便后端存储
                    if (value) {
                        let formatter = 'yyyy-MM-dd';
                        if (self.prop.datetype === 'date' || self.prop.datetype === 'daterange') {
                            formatter = 'yyyy-MM-dd';
                        } else if (self.prop.datetype === 'datetime' || self.prop.datetype === 'datetimerange') {
                            formatter = 'yyyy-MM-dd hh:mm:ss';
                        } else if (self.prop.datetype === 'year') {
                            formatter = 'yyyy';
                        } else if (self.prop.datetype === 'month') {
                            formatter = 'yyyy-MM';
                        }
                        value = dateUtil.parse(value, formatter);
                    } else {
                        value = null;
                    }
                    self.$set(self.prop, 'value', value ? value.getTime() : value);
                    self.$emit('handleChangeVal', value, self);
                }
            },
            style: {
                width: '100%'
            }
        })
    ];
};
