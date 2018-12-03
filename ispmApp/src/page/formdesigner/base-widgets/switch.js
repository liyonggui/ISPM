/**
 * 开关组件
 */
export default (self, h) => {
    return [
        h("i-switch", {
            props: {
                value: self.prop.name && self.data[self.prop.name] ? (self.data[self.prop.name] ? true : false) : (self.prop.value ? true : false)
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
        }, self.prop.switch.map((option, index) => {
            return h("span", {
                slot: option.slot,
                key: index,
                domProps:{
                    innerHTML: option.label
                }
            });
        }))
    ];
  };