# IP Blacklist from bjos.cn

Retrieve bad IP addresses from https://bjos.cn daily.

## Usage

To get all bad IP addresses, run:

```sh
$ curl --compressed -fsSL https://raw.githubusercontent.com/qianbinbin/ip-blacklist-bjos_cn/master/all.txt
```

To get 100000 worst IP addresses, run:

```sh
$ curl --compressed -fsSL https://raw.githubusercontent.com/qianbinbin/ip-blacklist-bjos_cn/master/all-count.txt 2>/dev/null | head -n 100000 | cut -f 1
```

To get IP addresses appear on at least 10 lists, run:

```sh
$ curl --compressed -fsSL https://raw.githubusercontent.com/qianbinbin/ip-blacklist-bjos_cn/master/all-count.txt | awk '$2>=10' | cut -f 1
```

## Credits

- https://bjos.cn
- [ipset-blacklist](https://github.com/trick77/ipset-blacklist)
- [ipsum](https://github.com/stamparm/ipsum)