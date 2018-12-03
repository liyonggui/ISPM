/**
 * 单选框组件
 */
export default (self, h) => {
    return [
        h("RadioGroup", {
            props: {
                value: self.prop.name ? (self.data[self.prop.name] || self.prop.value || '') : (self.prop.value || '')
            },
            on: {
                'on-change': (value) => {
                    if (!self.prop.name) {
                        return false;
                    }
                    self.$set(self.prop, 'value', value);
                    self.$emit('handleChangeVal', value, self);
                }
            }
        }, self.prop.dict.options.map(option => {
            return h("Radio", {
                props: {
                    label: option.value
                }
            }, option.label);
        }))
    ];
};