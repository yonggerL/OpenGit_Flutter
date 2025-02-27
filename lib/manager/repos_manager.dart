import 'dart:convert';

import 'package:open_git/bean/branch_bean.dart';
import 'package:open_git/bean/event_bean.dart';
import 'package:open_git/bean/release_bean.dart';
import 'package:open_git/bean/repos_bean.dart';
import 'package:open_git/bean/source_file_bean.dart';
import 'package:open_git/bean/trending_bean.dart';
import 'package:open_git/http/api.dart';
import 'package:open_git/http/http_manager.dart';
import 'package:open_git/util/html_util.dart';
import 'package:open_git/util/markdown_util.dart';
import 'package:open_git/util/trending_util.dart';

class ReposManager {
  factory ReposManager() => _getInstance();

  static ReposManager get instance => _getInstance();
  static ReposManager _instance;

  ReposManager._internal() {}

  static ReposManager _getInstance() {
    if (_instance == null) {
      _instance = new ReposManager._internal();
    }
    return _instance;
  }

  getReposDetail(reposOwner, reposName) async {
    String url = Api.getReposDetail(reposOwner, reposName);
    final response = await HttpManager.doGet(url, null);
    if (response != null && response.data != null) {
      return Repository.fromJson(response.data);
    }
    return null;
  }

  getReadme(reposFullName, branch) async {
    String url = Api.readmeFile(reposFullName, branch);
    return await getFileAsStream(url, false);
  }

  getReposStar(reposOwner, reposName) async {
    String url = Api.getReposStar(reposOwner, reposName);
    return await HttpManager.doGet(url, null);
  }

  getReposWatcher(reposOwner, reposName) async {
    String url = Api.getReposWatcher(reposOwner, reposName);
    return await HttpManager.doGet(url, null);
  }

  doReposStarAction(reposOwner, reposName, bool isEnable) async {
    String url = Api.getReposStar(reposOwner, reposName);
    if (isEnable) {
      return await HttpManager.doDelete(url, null, null);
    } else {
      return await HttpManager.doPut(url);
    }
  }

  doRepossWatcherAction(reposOwner, reposName, bool isEnable) async {
    String url = Api.getReposWatcher(reposOwner, reposName);
    if (isEnable) {
      return await HttpManager.doDelete(url, null, null);
    } else {
      return await HttpManager.doPut(url);
    }
  }

  getReposEvents(reposOwner, reposName, page) async {
    String url = Api.getReposEvents(reposOwner, reposName) +
        Api.getPageParams("&", page);
    final response = await HttpManager.doGet(url, null);
    if (response != null && response.data != null && response.data.length > 0) {
      List<EventBean> list = new List();
      for (int i = 0; i < response.data.length; i++) {
        var dataItem = response.data[i];
        list.add(EventBean.fromJson(dataItem));
      }
      return list;
    }
    return null;
  }

  getBranches(reposOwner, reposName) async {
    String url = Api.getBranches(reposOwner, reposName);
    final response = await HttpManager.doGet(url, null);
    if (response != null && response.data != null && response.data.length > 0) {
      List<BranchBean> list = new List();
      for (int i = 0; i < response.data.length; i++) {
        var dataItem = response.data[i];
        list.add(BranchBean.fromJson(dataItem));
      }
      return list;
    }
    return null;
  }

  getTrending(since, languageType) async {
    String url = Api.getTrending(since, languageType);
    final response = await HttpManager.doGet(url, null);
    if (response != null && response.data != null) {
      var repos = TrendingUtil.htmlToRepo(response.data);
      print("repos length is " + repos.length.toString());
      if (repos != null && repos.length > 0) {
        List<TrendingBean> list = new List();
        for (int i = 0; i < repos.length; i++) {
          var dataItem = repos[i];
          list.add(dataItem);
        }
        return list;
      }
    }
    return null;
  }

  getLanguages(language, page) async {
    String url = Api.getLanguages(language + Api.getPageParams("&", page));
    final response = await HttpManager.doGet(url, null);
    if (response != null && response.data != null && response.data.length > 0) {
      List<Repository> list = new List();
      var items = response.data["items"];
      for (int i = 0; i < items.length; i++) {
        var dataItem = items[i];
        list.add(Repository.fromJson(dataItem));
      }
      return list;
    }
    return null;
  }

  getReposFileDir(userName, reposName, {path = '', branch}) async {
    String url = Api.reposDataDir(userName, reposName, path, branch);
    final response = await HttpManager.doGet(url, null);
    if (response != null && response.data != null && response.data.length > 0) {
      List<SourceFileBean> dirs = new List();
      List<SourceFileBean> files = new List();
      for (int i = 0; i < response.data.length; i++) {
        SourceFileBean file = SourceFileBean.fromJson(response.data[i]);
        if (file.type == "file") {
          files.add(file);
        } else {
          dirs.add(file);
        }
      }
      List<SourceFileBean> list = new List();
      list.addAll(dirs);
      list.addAll(files);
      return list;
    }
    return null;
  }

  getFileAsStream(url, bool isParse) async {
    final response = await HttpManager.doGet(
        url, {"Accept": 'application/vnd.github.VERSION.raw'});
    if (response != null && response.data != null) {
      if (!isParse) {
        return response.data;
      }
      String result;
      if (MarkdownUtil.isMarkdown(url)) {
        result = response.data;
      } else {
        String html = HtmlUtil.generateCodeHtml(
            response.data, null, false, "#ffffff", false, true);
        result = new Uri.dataFromString(html,
                mimeType: 'text/html', encoding: Encoding.getByName("utf-8"))
            .toString();
      }
      return result;
    }
    return null;
  }

  getReposReleases(userName, repos, {page = 1}) async {
    String url =
        Api.getReposReleases(userName, repos) + Api.getPageParams("&", page);
    final response = await HttpManager.doGet(url, null);
    if (response != null && response.data != null && response.data.length > 0) {
      List<ReleaseBean> list = new List();
      for (int i = 0; i < response.data.length; i++) {
        var dataItem = response.data[i];
        list.add(ReleaseBean.fromJson(dataItem));
      }
      return list;
    }
    return null;
  }
}
