let interval = null

function queryContainerStatus(vue, app) {
  let containers = []
  let envsMap = {}
  if(app.environments) {
    app.environments.forEach((env, index) => {
      if(env.containers) {
        env.containers.forEach((container, index) => {
          let containerId = container.id
          containers.push(containerId)
          envsMap[containerId] = container
        });
      }
    })
  }
  if(containers.length <= 0) return

  let fileter = {
    where: {
      and: [
        {
          id: {
            in: containers
          }
        }
      ]
    }
  }
  vue.$axios.get("/ContainerService/states", {data: [fileter]}).then((resp) => {
    let containers = resp.data
    containers.forEach((container, index) => {
      if(envsMap.hasOwnProperty(container.id)) {
        vue.$set(envsMap[container.id], 'state', container.state)
        vue.$set(envsMap[container.id], 'healthstatus', healthStatusCalc(container))
        vue.$set(envsMap[container.id], 'taskStatus', container.currentTask && container.currentTask.status)
        vue.$set(envsMap[container.id], 'taskError', container.currentTask && container.currentTask.exceptionMsg)
      }
    });
  })
}

function healthStatusCalc(container) {
  let taskKpi = container.taskKpi
  if (taskKpi) {
    let total = 0
    let end = 0
    if(taskKpi.hasOwnProperty('End')) {
      total += taskKpi.End
      end = taskKpi.End
    }
    if(taskKpi.hasOwnProperty('Error')) {
      total += taskKpi.Error
    }
    let rate = end / total
    if(rate >= 0.75) {
      return "sun"
    } else if (rate >= 0.5 && rate < 0.75) {
      return "cloudy"
    } else if (rate >= 0.25 && rate < 0.5) {
      return "rain"
    } else if(rate >= 0 && rate < 0.25) {
      return "thunder"
    } else {
      return ""
    }
  } else {
    return ''
  }
}

export function pollingStatus (vue, app) {
  queryContainerStatus(vue, app)
  interval = setInterval(() => {
    queryContainerStatus(vue, app)
  }, 5000)
}

export function destroyPolling () {
  console.log('destroyPolling')
  if(interval) {
    clearInterval(interval)
    interval = null
  }
}
