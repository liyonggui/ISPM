export default (self, colIndex, h) => {
    // transition-group
    const transitionGroup = h('transition-group', {
        class: {
            'form-list-group': true
        },
        props: {
            type: 'transition',
            name: 'flip-list',
            tag: "div"
        }
    }, self.prop.widgets[colIndex].map((widget, idx) => {
        return h('tile', {
            key: idx,
            props: {
                index: idx,
                name: widget.name,
                prop: widget.prop || {},
                data: self.data,
                widgetList: self.prop.widgets[colIndex],
                config: self.config
            },
            on: {
                handleRemoveElement: (index, widgetList) => {
                    self.$emit('handleRemoveElement', index, widgetList);
                },
                handleConfigElement: (index, widgetList) => {
                    self.$emit('handleConfigElement', index, widgetList);
                },
                handleCopyElement: (index, widgetList) => {
                    self.$emit('handleCopyElement', index, widgetList);
                },
                handleChangeVal: (val, element) => {
                    self.$emit('handleChangeVal', val, element);
                }
            }
        });
    }));
    // draggable
    const draggable = h('draggable', {
        props: {
            list: self.prop.widgets[colIndex],
            options: {
                animation: 0,
                ghostClass: 'ghost',
                group: {
                    name: 'widget',
                    put: ['widget', 'layout'],
                    pull: true
                }
            }
        }
    }, [transitionGroup]);
    // 搞定
    return draggable;
};
