export default (self, h) => {
    let icons = [];
    // 复制按钮
    if (self.prop.copy) {
        icons.push(h('Button', {
            props: {
                type: 'primary',
                icon: 'md-copy',
                size: 'small',
                ghost: true
            },
            nativeOn: {
                click () {
                    self.$emit('handleCopyElement', self.index, self.widgetList);
                }
            }
        }, '复制'));
    }
    // 配置按钮
    if (self.prop.config) {
        icons.push(h('Button', {
            props: {
                type: 'success',
                icon: 'md-settings',
                color: '#fff',
                size: 'small',
                ghost: true
            },
            nativeOn: {
                click () {
                    self.$emit('handleConfigElement', self.index, self.widgetList);
                }
            },
            style: {
                'margin-left': '2px'
            }
        }, '编辑'));
    }
    // 删除按钮
    icons.push(h('Button', {
        props: {
            type: 'error',
            icon: 'md-close',
            size: 'small',
            ghost: true
        },
        nativeOn: {
            click () {
                self.$emit('handleRemoveElement', self.index, self.widgetList);
            }
        },
        style: {
            'margin-left': '2px'
        }
    }, '删除'));
    const tileBar = h('div', {
        class: {
            'tile-bar': true,
            'layout-tile-bar': ['layout1', 'layout2', 'layout3', 'layout4'].indexOf((self.name.toLowerCase())) < 0 ? false : true
        }
    }, icons);
    return tileBar;
};
