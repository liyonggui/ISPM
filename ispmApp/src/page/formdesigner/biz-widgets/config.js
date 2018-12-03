/**
 * 所有的业务组件配置
 */
import orgSelectConfig from './config/orgselect';
import areaConfig from './config/area';

const components = {
    orgSelect: orgSelectConfig,
    area: areaConfig
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