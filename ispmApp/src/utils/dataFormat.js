function resourceFormat(resources) {
  let operations = {};
  function recursionResource(resources) {
    let children = resources.children
    children.forEach((resource) => {
      if(resource.type == "action") {
        let operationCode = resource.operation.code;
        if(operationCode) {
          operations[operationCode] = resources.path;
        }
      }
      if(resource.children) {
        recursionResource(resource)
      }
    })
  }
  recursionResource({children: resources})
  return operations;
}

export {
  resourceFormat
}
