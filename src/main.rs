use futures::prelude::*;
use k8s_openapi::api::apps::v1::Deployment;
use k8s_openapi::api::core::v1::Pod;
use kube::api::ListParams;
use kube::{
    api::{Api, ResourceExt},
    client::ConfigExt,
    runtime::{watcher, WatchStreamExt},
    Client, Config,
};
use tracing::*;
mod api;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt::init();

    let config = Config::infer().await?;
    let client = Client::try_default().await?;

    let https = config.openssl_https_connector()?;
    let service = tower::ServiceBuilder::new()
        .layer(config.base_uri_layer())
        .service(hyper::Client::builder().build(https));
    kube::Client::new(service, config.default_namespace);

    let api = Api::<Deployment>::namespaced(client.clone(), "dev");
    let pods = Api::<Pod>::namespaced(client, "dev");

    let lp = ListParams::default().labels("msdk/ms-name=CMPS"); // for this app only
    for p in pods.list(&lp).await? {
        info!("Found Pod: {}", p.name_any());
        info!("Status: {:?}", p.status.unwrap().container_statuses);
    }

    watcher(api, watcher::Config::default())
        .applied_objects()
        .try_for_each(|p| async move {
            info!("saw {}", p.name_any());
            info!("saw {:?}", p.labels());

            for (k, v) in p.labels() {
                if "msdk/ms-name" == k {
                    let mut s = api::services::sync_ms::SyncService::new();
                    // s.do_auth().await.unwrap();
                    // s.sync_ms(String::from(v)).await;
                }
                // match (k, v) {
                //     (l, _) => {
                //         let mut s = api::services::sync_ms::SyncService::new();
                //         s.do_auth().await.unwrap();
                //         s.sync_ms(String::from(v)).await;
                //     }
                //     _ => {}
                // };
            }

            // if let Some(unready_reason) = pod_unready(&p) {
            //     warn!("{}", unready_reason);
            // }

            Ok(())
        })
        .await?;
    Ok(())
}

// fn pod_unready(p: &Pod) -> Option<String> {
//     let status = p.status.as_ref().unwrap();
//     if let Some(conds) = &status.conditions {
//         let failed = conds
//             .iter()
//             .filter(|c| c.type_ == "Ready" && c.status == "False")
//             .map(|c| c.message.clone().unwrap_or_default())
//             .collect::<Vec<_>>()
//             .join(",");
//         if !failed.is_empty() {
//             if p.metadata.labels.as_ref().unwrap().contains_key("job-name") {
//                 return None; // ignore job based pods, they are meant to exit 0
//             }
//             return Some(format!("Unready pod {}: {}", p.name_any(), failed));
//         }
//     }
//     None
// }
