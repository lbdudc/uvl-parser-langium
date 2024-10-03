import { FeatureModel } from '../language/generated/ast.js';
import { EmptyFileSystem } from 'langium';
import { parseHelper } from 'langium/test';
import { createUvlparserServices } from '../language/uvlparser-module.js';


export async function parseDocument(featureModel: FeatureModel, filePath: string, destination: string | undefined): Promise<FeatureModel> {
    const services = createUvlparserServices(EmptyFileSystem);
    const parse = parseHelper<FeatureModel>(services.Uvlparser);
    const document = await parse(FeatureModel);
    const model = document.parseResult.value
    console.log(model);
    return model;
}