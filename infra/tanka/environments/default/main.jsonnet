// tanka/environment/default/main.jsonnet
local grafana() = {
  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'grafana',
    },
    spec: {
      selector: {
        matchLabels: {
          name: 'grafana',
        },
      },
      template: {
        metadata: {
          labels: {
            name: 'grafana',
          },
        },
        spec: {
          containers: [
            {
              image: 'grafana/grafana',
              name: 'grafana',
              ports: [{
                  containerPort: 3000,
                  name: 'ui',
              }],
            },
          ],
        },
      },
    },
  },
  service: {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      labels: {
        name: 'grafana',
      },
      name: 'grafana',
    },
    spec: {
      ports: [{
          name: 'grafana-ui',
          port: 3000,
          targetPort: 3000,
      }],
      selector: {
        name: 'grafana',
      },
      type: 'NodePort',
    },
  },
};

{
   grafana:  grafana(),
}

