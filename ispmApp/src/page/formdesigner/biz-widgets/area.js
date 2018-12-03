/**
 * 区域选择组件
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
        h('al-cascader', {
            props: {
                value: initValue,
                size: 'default',
                placeholder: self.prop.placeholder || '',
                level: self.prop.level || 3
            },
            on: {
                'on-change': (value) => {
                    if (!self.prop.name) {
                        return;
                    }
                    let values;
                    value.forEach(element => {
                        if (values) {
                            values += (',' + element.code);
                        } else {
                            values = element.code;
                        }
                    });
                    self.$set(self.prop, 'value', values);
                    self.$emit('handleChangeVal', values, self);
                }
            }
        })
    ];
};
