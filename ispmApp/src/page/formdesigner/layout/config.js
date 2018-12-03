/**
 * 所有的layout配置
 */
import layout1Config from './config/layout1';
import layout2Config from './config/layout2';
import layout3Config from './config/layout3';
import layout4Config from './config/layout4';

const components = {
    layout1: layout1Config,
    layout2: layout2Config,
    layout3: layout3Config,
    layout4: layout4Config
};
// map -> list
let componentsList = [];
for (let i in components) {
    componentsList.push({
        name: i,
        prop: components[i]
    });
}
export default componentsList;