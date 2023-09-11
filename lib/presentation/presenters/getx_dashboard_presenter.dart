import 'dart:developer';

import 'package:get/get.dart';

import 'package:mobcar/domain/usecases/usecases.dart';
import 'package:mobcar/ui/pages/pages.dart';

class GetxDashboardPresenter extends GetxController implements DashboardPresenter {
  GetxDashboardPresenter({
    required this.loadBrands,
    required this.loadModels,
    required this.loadYears,
    required this.loadFipeInfo,
    required this.saveFipeInfo,
    required this.loadFipeInfos,
  });

  final LoadBrands loadBrands;
  final LoadModels loadModels;
  final LoadYears loadYears;
  final LoadFipeInfo loadFipeInfo;
  final SaveFipeInfo saveFipeInfo;
  final LoadFipeInfos loadFipeInfos;

  BrandViewEntity? _brand;
  ModelViewEntity? _model;
  YearViewEntity? _year;
  FipeInfoViewEntity? _fipeInfo;
  List<FipeInfoViewEntity>? _fipeInfos;

  final _isLoadingController = Rx<bool>(false);
  final _brandController = Rx<List<BrandViewEntity>?>(null);
  final _modelController = Rx<List<ModelViewEntity>?>(null);
  final _yearController = Rx<List<YearViewEntity>?>(null);
  final _fipeInfoController = Rx<FipeInfoViewEntity?>(null);
  final _fipeInfosController = Rx<List<FipeInfoViewEntity>?>(null);

  @override
  void setBrand(BrandViewEntity? value) => _brand = value;
  @override
  void setModel(ModelViewEntity? value) => _model = value;
  @override
  void setYear(YearViewEntity? value) => _year = value;
  @override
  void setFipeInfo(FipeInfoViewEntity? value) => _fipeInfo = value;

  @override
  BrandViewEntity? get brand => _brand;
  @override
  ModelViewEntity? get model => _model;
  @override
  YearViewEntity? get year => _year;
  @override
  FipeInfoViewEntity? get fipeInfo => _fipeInfo;
  @override
  List<FipeInfoViewEntity>? get fipeInfos => _fipeInfos;

  @override
  Stream<bool> get isLoadingStream => _isLoadingController.stream;
  @override
  Stream<List<BrandViewEntity>?> get brandStream => _brandController.stream;
  @override
  Stream<List<ModelViewEntity>?> get modelStream => _modelController.stream;
  @override
  Stream<List<YearViewEntity>?> get yearStream => _yearController.stream;
  @override
  Stream<FipeInfoViewEntity?> get fipeInfoStream => _fipeInfoController.stream;
  @override
  Stream<List<FipeInfoViewEntity>?> get fipeInfosStream => _fipeInfosController.stream;

  @override
  Future<void> loadBrandsData() async {
    try {
      _isLoadingController.value = true;
      final brands = await loadBrands.load();
      _brandController.subject.add(brands.map((brand) => BrandViewEntity(name: brand.name, code: brand.code)).toList());
    } catch(error) {
      log(error.toString());
    } finally {
      _isLoadingController.value = false;
    }
  }

  @override
  Future<void> loadModelsData() async {
    try {
      _isLoadingController.value = true;
      final brands = await loadModels.load(_brand!.code);
      _modelController.subject.add(brands.map((model) => ModelViewEntity(name: model.name, code: model.code)).toList());
    } catch(error) {
      log(error.toString());
    } finally {
      _isLoadingController.value = false;
    }
  }

  @override
  Future<void> loadYearsData() async {
    try {
      _isLoadingController.value = true;
      final years = await loadYears.load(brand: _brand!.code, model: _model!.code);
      _yearController.subject.add(years.map((year) => YearViewEntity(name: year.name, code: year.code)).toList());
    } catch(error) {
      log(error.toString());
    } finally {
      _isLoadingController.value = false;
    }
  }

  @override
  Future<void> loadFipeInfoData() async {
    try {
      _isLoadingController.value = true;
      final fipeInfo = await loadFipeInfo.load(brand: _brand!.code, model: _model!.code, year: _year!.code);
      final fipeViewEntity = FipeInfoViewEntity(
        price: fipeInfo.price,
        brand: fipeInfo.brand,
        model: fipeInfo.model,
        modelYear: fipeInfo.modelYear,
      );
      _fipeInfoController.subject.add(fipeViewEntity);
      setFipeInfo(fipeViewEntity);
    } catch(error) {
      log(error.toString());
    } finally {
      _isLoadingController.value = false;
    }
  }

  @override
  Future<void> loadFipeInfosData() async {
    try {
      _isLoadingController.value = true;
      final fipeInfos = await loadFipeInfos.load();
      _fipeInfos = fipeInfos.map((item) => FipeInfoViewEntity(
        price: item.price,
        brand: item.brand,
        model: item.model,
        modelYear: item.modelYear,
      )).toList();
      _fipeInfosController.subject.add(_fipeInfos);
    } catch(error) {
      log(error.toString());
    } finally {
      _isLoadingController.value = false;
    }
  }

  @override
  Future<void> save() async {
    _fipeInfos = _fipeInfos?.cast() ?? []..add(_fipeInfo!);
    await saveFipeInfo.save(_fipeInfos!.map((fipe) => fipe.toDomainEntity()).toList());
    _fipeInfosController.subject.add(_fipeInfos);
  }

  @override
  void dispose() {
    _isLoadingController.close();
    _brandController.close();
    _modelController.close();
    _yearController.close();
    _fipeInfoController.close();
    _fipeInfosController.close();
    super.dispose();
  }
  
}
