/**
 * 评分组件
 */
export default (self, h) => {
    return [
        h("Rate", {
            props: {
                value: self.prop.name && self.data[self.prop.name] ? Number(self.data[self.prop.name]) : (Number(self.prop.value) || 0),
                count: self.prop.count || 5,
                'allow-half': self.prop['allow-half'] || false
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
        })
    ];
};