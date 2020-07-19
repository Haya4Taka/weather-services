# weather-services
気象情報サービスの環境設定

## features
・EKSによるコンテナ管理  
・CloudFormationによるAWSリソース管理  
・DBスキーマ、シードデータ

## requirement
* dokcer
* kubectl 1.16+
* eksctl 0.23+
* aws cli 1.18.97+

## provisioning
### AWSリソースの作成
*cliの例を示すが、AWSコンソールのCloudFormationからも作成可能  

VPC,Subnetなどの作成  
```
aws cloudformation create-stack \
  --stack-name weather-services-base \
  --region ap-northeast-1 \
  --template-body file://cfn/base.yaml
```
RDSの作成
```
aws cloudformation create-stack \
  --stack-name weather-services-rds \
  --region ap-northeast-1 \
  --template-body file://cfn/rds.yaml \
  --parameters \
  ParameterKey=BaseVPC,ParameterValue=<VPCのId> \
  ParameterKey=JumpRouteTalbe,ParameterValue=<JumpRouteTableのId>
```
その他リソース  
テスト用RDS：cfn/rds_test.yaml

### テーブルの作成  
RDSへの踏み台サーバーがcfnにより作成されるので、  
AWSコンソールのSystemsManagerより踏み台サーバーにアクセスし、下記を実行。

```
yum install -y git
git clone https://github.com/Haya4Taka/weather-services.git
mysql -h <rds-host> -u <username> -p weather_services < ./db/ddl.sql
mysql -h <rds-host> -u <username> -p weather_services < ./db/dml.sql
```
*RDSのホスト名はスタックのOutputに、パスワード、ユーザー名はSecretsManagerで確認できます。

### kubernetes環境の作成
clusterの作成  
*subnetのIdは手動で設定ファイルに記載する
```
eksctl create cluster -f k8s/cluster.yaml # clusetrの作成
```
namespaceの作成
```
kubectl apply -f k8s/namespace.yaml # namespaceの作成
kubectl config get-contexts # namespaceの確認(次のコマンドで必要)
kubectl config set-context weather-services --cluster 上記CLUSTERの値 \
--user AUTHINFOの値 \
--namespace weather-services # namespaceをkubeconfigに登録
```
DB、APIの接続情報の登録
```
DB_URL=<RDSエンドポイント> \
DB_PASSWORD=<DBのパスワード> \
envsubst < k8s/db_config.yaml | \
kubectl apply -f -

API_KEY=<OpenWeatherMapのAPI_KEY> \
envsubst < k8s/weather_api_secret | \
kubectl apply -f -
```
定期取得サービスのデプロイ  
*イメージをECRにpushしている前提
```
ECR_HOST=<ECRホスト名> \
envsubst < k8s/cronjob.yaml | \
kubectl apply -f -
```
天候情報出力サービスのデプロイ  
*イメージをECRにpushしている前提
```
ECR_HOST=<ECRホスト名> \
envsubst < k8s/weather_api.yaml | \
kubectl apply -f -
```