// 各種パッケージを読み込み
const express = require('express');
const mysql = require('mysql');

// MySQLへの接続設定
const db = mysql.createConnection({
  host: '',
  user: 'yossy',
  password: '',
  database: 'autoscale'
});

// MySQLへ接続
db.connect((err) => {
  if (err) {
    throw err;
  }
  console.log('Connected to MySQL');
});

// Expressアプリ初期化
const app = express();

// ルートアクセス時にDBテスト
app.get('/', (req, res) => {
  let sql = 'SHOW DATABASES';
  db.query(sql, (err, result) => {
    if(err) {
      res.send('Error fetching rows');
    } else {
      console.log(result);
      res.send('Rows fetched');
    }
  });
});

const port = 3000;

// サーバ起動
app.listen(port, () => console.log(`Server listening on port ${port}`));
