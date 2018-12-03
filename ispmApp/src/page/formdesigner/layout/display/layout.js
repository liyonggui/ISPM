/**
 * layout布局 - preview
 * 现在目前都是类excel表单，使用传统table吧
 */
export default (self, h) => {
    let rows = [];
    const rowNum = self.prop.row ? self.prop.row : 1;
    const colNum = self.prop.col ? self.prop.col : 1;
    // 行
    for (let i=0; i<rowNum; i++) {
        let cols = [];
        // 列
        for (let j=0; j<colNum; j++) {
            const children = h('div', {
                class: {
                    'form-list-group': true
                }
            }, self.prop.widgets[j].map((widget, idx) => {
                return h('tile', {
                    key: idx,
                    props: {
                        index: idx,
                        name: widget.name,
                        prop: widget.prop || {},
                        data: self.data,
                        widgetList: self.prop.widgets[j],
                        config: self.config,
                        disabled: self.disabled
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
            const col = h('td', {
                class: {
                    'table-col': true
                },
                style: {
                    width: self.prop.span[j] / 24 * 100 + '%',
                    'border-top-style': self.prop.border.top ? 'solid' : 'none',
                    'border-right-style': self.prop.border.right ? 'solid' : 'none',
                    'border-bottom-style': self.prop.border.bottom ? 'solid' : 'none',
                    'border-left-style': self.prop.border.left ? 'solid' : 'none'
                }
            }, [children]);
            cols.push(col);
        }
        const row = h('tr', {
            class: {
                'table-row': true
            }
        }, cols);
        // 容器：通过样式在页面展示出区域
        const container = h('table', {
            class: {
                'table-container': true
            },
            attrs: {
                cellspacing: '0',
                cellpadding: '0' 
            }
        }, [row]);
        rows.push(container);
    }
    return rows;
};