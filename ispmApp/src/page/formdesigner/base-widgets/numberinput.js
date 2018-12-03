/**
 * 输入框组件
 */
export default (self, h) => {
    return [
        h('number-input', {
            props: {
                size: 'default',
                max: Number(self.prop.max) || Infinity,
                min: Number(self.prop.min) || -Infinity,
                decimal: Number(self.prop.decimal) || 0,
                value: self.prop.name && self.data[self.prop.name] ? Number(self.data[self.prop.name]) : (Number(self.prop.value) || 0)
            },
            on: {
                'input': value => {
                    if (!self.prop.name) {
                        return;
                    }
                    self.$set(self.prop, 'value', value);
                    self.$emit('handleChangeVal', value, self);
                }
            }
        })
    ];
};
