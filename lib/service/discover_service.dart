import '../utils/http_utils.dart';
import 'package:flutter_chaofan/api/api.dart';

typedef OnSuccessList<T>(List<T> banners);

typedef OnFail(String message);

typedef OnSuccess<T>(T data);

class DiscoverService {
  // Future getCategoryData(OnSuccessList onSuccessList, {OnFail onFail}) async {
  //   try {
  //     var responseList = [];
  //     var response = await HttpUtil.instance.get(Api.HOME_FIRST_CATEGORY);
  //     if (response['errno'] == 0) {
  //       responseList = response['data'];
  //       FirstLevelListCategory firstLevelListCategory =
  //           FirstLevelListCategory.fromJson(responseList);
  //       onSuccessList(firstLevelListCategory.firstLevelCategory);
  //     } else {
  //       onFail(response['errorMessage']);
  //     }
  //   } catch (e) {
  //     print(e);
  //     onFail(Strings.SERVER_EXCEPTION);
  //   }
  // }

  // Future getSubCategoryData(
  //     Map<String, dynamic> parameters, OnSuccessList onSuccessList,
  //     {OnFail onFail}) async {
  //   try {
  //     var responseList = [];
  //     var response = await HttpUtil.instance
  //         .get(Api.HOME_SECOND_CATEGORY, parameters: parameters);
  //     if (response['errno'] == 0) {
  //       responseList = response['data'];
  //       SubCategoryListEntity subCategoryListEntity =
  //           SubCategoryListEntity.fromJson(responseList);
  //       onSuccessList(subCategoryListEntity.subCategoryEntitys);
  //     } else {
  //       onFail(response['errorMessage']);
  //     }
  //   } catch (e) {
  //     print(e);
  //     onFail(Strings.SERVER_EXCEPTION);
  //   }
  // }

  Future getListTags(Map<String, dynamic> parameters, OnSuccess onSuccess,
      OnFail onFail) async {
    try {
      var response =
          await HttpUtil.instance.get(Api.ListTags, parameters: parameters);
      var data =
          await HttpUtil().get(Api.ListForumsByTag, parameters: {"tagId": 0});
      List arr = [];
      if (response['success'] && data['success']) {
        // CategoryTitleEntity categoryTitleEntity =
        //     CategoryTitleEntity.fromJson(response["data"]);
        // print(response["data"]);
        arr.add(response["data"]);
        arr.add(data["data"]);
        onSuccess(arr);
      } else {
        onFail(response['errorMessage']);
      }
    } catch (e) {
      print(e);
      // onFail(Strings.SERVER_EXCEPTION);
    }
  }
}
