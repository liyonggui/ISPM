/**
 * 输入框组件
 */
export default (self, h) => {
    return [
        h('Input', {
            props: {
                placeholder: self.prop.placeholder || '输入框',
                maxlength: Number(self.prop.maxlength) || 50,
                value: self.prop.name ? (self.data[self.prop.name] || self.prop.value || '') : (self.prop.value || '')
            },
            on: {
                'on-change': e => {
                    if (!self.prop.name) {
                        return;
                    }
                    self.$set(self.prop, 'value', e.currentTarget.value);
                    self.$emit('handleChangeVal', e.currentTarget.value, self);
                }
            }
        })
    ];
};
