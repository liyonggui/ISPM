/**
 * layout布局
 * 目前只支持单行，需要多行插入多个即可
 * 只支持行删除，列删除相当于改变布局，已经算是换控件了
 * TODO: 拖动layout的时候填行数
 */
export default (self, h) => {
    const draggableComponent = require(`../components/draggable`).default;
    let rows = [];
    const rowNum = self.prop.row ? self.prop.row : 1;
    const colNum = self.prop.col ? self.prop.col : 1;
    // 行
    for (let i=0; i<rowNum; i++) {
        let cols = [];
        // 列
        for (let j=0; j<colNum; j++) {
            const draggable = draggableComponent(self, j, h);
            // 容器：通过样式在页面展示出区域
            const draggableContainer = h('div', {
                class: {
                    'draggable-container': true
                },
                style: {
                    'border-top-style': self.prop.border.top ? 'solid' : 'dashed',
                    'border-right-style': self.prop.border.right ? 'solid' : 'dashed',
                    'border-bottom-style': self.prop.border.bottom ? 'solid' : 'dashed',
                    'border-left-style': self.prop.border.left ? 'solid' : 'dashed'
                }
            }, [draggable]);
            const col = h('Col', {
                props: {
                    span: self.prop.span[j]
                },
                class: {
                    'layout-col': true
                }
            }, [draggableContainer]);
            cols.push(col);
        }
        const row = h('Row', {
            style: {
                margin: '0px'
            },
            class: {
                'layout-row': true
            },
            props: {
                gutter: 4
            }
        }, cols);
        // 容器：通过样式在页面展示出区域
        const container = h('div', {
            class: {
                'layout-row-container': true
            }
        }, [row]);
        rows.push(container);
    }
    return rows;
};