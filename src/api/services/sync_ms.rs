use anyhow::Error;
use hyper::header::{AUTHORIZATION, CONTENT_TYPE};
use reqwest::ClientBuilder;
use serde_json::Value;
use tracing::info;

pub struct SyncService {
    c: reqwest::Client,
    token: String,
}

impl SyncService {
    pub fn new() -> Self {
        let b = ClientBuilder::new();
        let client = b.danger_accept_invalid_certs(true).build().unwrap();
        Self {
            c: client,
            token: String::from(""),
        }
    }

    pub async fn do_auth(&mut self) -> Result<(), Error> {
        // This will POST a body of `foo=bar&baz=quux`
        // The code snippet is performing an HTTP POST request using the reqwest library in Rust.

        let params = [
            ("grant_type", "password"),
            ("username", "superuser"),
            ("password", "tms4us"),
            ("scope", "corelib openid profile roles"),
            ("client_id", "ro.client"),
            ("acr_values", "tenant:NA"),
        ];
        let res = self
            .c
            .post("https://idp.localhost/connect/token")
            .header(CONTENT_TYPE, "application/x-www-form-urlencoded")
            .header(AUTHORIZATION, "Basic cm8uY2xpZW50OnNlY3JldA==")
            .form(&params)
            .send()
            .await
            .unwrap();
        info!("{:?}", res.status());

        let content = res.text().await.unwrap();
        // Parse the string of data into serde_json::Value.
        let v: Value = serde_json::from_str(content.as_str()).unwrap();

        self.token = v["access_token"].to_string().replace('"', "");
        println!("{:?}", v["access_token"]);

        Ok(())
    }

    pub async fn sync_ms(self, ms_name: String) {
        let res = self
            .c
            .get(format!(
                "https://default.localhost/api/MSManager/sync?ui=false&db=true&msName={}",
                ms_name
            ))
            .header(AUTHORIZATION, format!("Bearer {}", self.token))
            .send()
            .await
            .unwrap();
        println!("{}", self.token);
        info!("{:?}", res.status());
        info!("{:?}", res.text().await.unwrap());
    }
}
