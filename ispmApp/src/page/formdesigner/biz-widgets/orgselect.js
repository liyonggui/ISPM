/**
 * 组织机构选择框组件
 */
export default (self, h) => {
    return [
        h('advance-input', {
            props: {
                size: 'default',
                value: self.prop.name && self.data[self.prop.name] ? JSON.parse(self.data[self.prop.name]) : (self.prop.value || ''),
                disabled: false,
                url: '/sys/office/list',
                placeholder: self.prop.placeholder || '',
                params: {delFlag: '0', pageSize: -1}
            },
            on: {
                'on-change': (value) => {
                    if (!self.prop.name) {
                        return;
                    }
                    self.$set(self.prop, 'value', value);
                    self.$emit('handleChangeVal', JSON.stringify(value), self);
                }
            }
        })
    ];
};
