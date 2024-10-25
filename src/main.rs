use futures::prelude::*;
use k8s_openapi::api::apps::v1::Deployment;
use k8s_openapi::api::core::v1::Pod;
use kube::api::ListParams;
use kube::{
    api::{Api, ResourceExt},
    // client::ConfigExt,
    runtime::{watcher, WatchStreamExt},
    Client,
    // Config,
};
use tokio::runtime::Builder;
use tracing::*;
mod api;
use std::env;
use std::{thread, time::Duration};

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt::init();

    // Read the TOKIO_WORKER_THREADS environment variable
    let worker_threads = env::var("TOKIO_WORKER_THREADS")
        .ok()
        .and_then(|s| s.parse::<f64>().ok())
        .map(|cpu| {
            // Round to the nearest integer
            let threads = cpu.round() as usize;
            if threads == 0 {
                1 // Ensure at least one thread
            } else {
                threads
            }
        })
        .unwrap_or_else(|| {
            // Fallback to detected CPUs if the environment variable is not set or invalid
            println!(
                "Environment variable TOKIO_WORKER_THREADS not set or invalid. Detected CPUs.",
            );
            1
        });

    println!(
        "Configuring Tokio runtime with {} worker threads.",
        worker_threads
    );

    let runtime = Builder::new_multi_thread()
        .worker_threads(worker_threads)
        .enable_all()
        .build()
        .expect("Failed to build Tokio runtime");

    thread::sleep(Duration::from_secs(10));

    runtime.block_on(async { real_main().await })


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
//
//
async fn real_main() -> anyhow::Result<()> {
    // let config = Config::infer().await?;
    let client = Client::try_default().await?;

    // let https = config.openssl_https_connector()?;
    // let service = tower::ServiceBuilder::new()
    //     .layer(config.base_uri_layer())
    //     .service(hyper::Client::builder().build(https));
    // kube::Client::new(service, config.default_namespace);

    let api = Api::<Deployment>::namespaced(client.clone(), "default");
    let pods = Api::<Pod>::namespaced(client, "default");

    let lp = ListParams::default().labels("owner/ms-name=CMPS"); // for this app only
    for p in pods.list(&lp).await? {
        info!("Found Pod: {}", p.name_any());
        info!("Status: {:?}", p.status.unwrap().container_statuses);
    }

    watcher(api, watcher::Config::default())
        .applied_objects()
        .try_for_each(|p| async move {
            info!("saw {}", p.name_any());
            info!("saw {:?}", p.labels());

            for k in p.labels().keys() {
                if "msdk/ms-name" == k {
                    let _s = api::services::sync_ms::SyncService::new();
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
