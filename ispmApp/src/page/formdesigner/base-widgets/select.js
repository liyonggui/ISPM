/**
 * 选择框组件
 */
export default (self, h) => {
    // 初始value
    let initValue = ''; 
    if (self.prop.name && self.data[self.prop.name]) {
        if (self.prop.multiple) {
            if (self.data[self.prop.name] instanceof Array) {
                initValue = (self.data[self.prop.name]);
            } else {
                initValue = (self.data[self.prop.name]).split(',');
            }
        } else {
            initValue = self.data[self.prop.name];
        }
    } else {
        if (self.prop.multiple) {
            if (self.prop.value) {
                if (self.prop.value instanceof Array) {
                    initValue = self.prop.value;
                } else {
                    initValue = self.prop.value.split(',');
                }
            } else {
                initValue = [];
            }
        } else {
            initValue = self.prop.value || '';
        }
    }
    return [
        h("Select", {
            props: {
                value: initValue,
                multiple: self.prop.multiple,
                // filterable: self.prop.filterable
                // Select组件有BUG，v-model值置空时，是不会清除之前的Option选中状态的，filterable不能用
                filterable: false
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
        }, self.$getDictByKey(self.prop.dict.type).map(option => {
            return h("Option", {
                props: {
                    label: option.label,
                    value: option.value,
                },
                key: option.id
            }, option.label);
        }))
    ];
};