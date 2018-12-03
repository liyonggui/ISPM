/**
 * 多选框组件
 */
export default (self, h) => {
    // 初始value
    let initValue = ''; 
    if (self.prop.name && self.data[self.prop.name]) {
        if (self.data[self.prop.name] instanceof Array) {
            initValue = (self.data[self.prop.name]);
        } else {
            initValue = (self.data[self.prop.name]).split(',');
        }
    } else {
        if (self.prop.value) {
            if (self.prop.value instanceof Array) {
                initValue = self.prop.value;
            } else {
                initValue = self.prop.value.split(',');
            }
        } else {
            initValue = [];
        }
    }
    return [
        h("CheckboxGroup", {
            props: {
                value: initValue
            },
            on: {
                'on-change': (value) => {
                    if (!self.prop.name) {
                        return false;
                    }
                    self.$set(self.prop, 'value', value.join(','));
                    self.$emit('handleChangeVal', value, self);
                }
            }
        }, self.prop.dict.options.map(option => {
            return h("Checkbox", {
                props: {
                    label: option.value
                }
            }, option.label);
        }))
    ];
};