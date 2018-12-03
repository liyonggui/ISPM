/**
 * 时间框组件
 */
import dateUtil from '../utils/date-util';

export default (self, h) => {
    return [
        h('TimePicker', {
            props: {
                placeholder: self.prop.placeholder || '时间框',
                type: self.prop.datetype || 'time',
                value: self.prop.name && self.data[self.prop.name] ? new Date(self.data[self.prop.name]) : (self.prop.value ? new Date(self.prop.value) : null),
                confirm: true
            },
            on: {
                'on-change': (value) => {
                    if (!self.prop.name) {
                        return false;
                    }
                    if (value) {
                        value = dateUtil.parse(value, 'HH:mm:ss');
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
