import { afterEach, beforeAll, describe, expect, test } from "vitest";
import { EmptyFileSystem, type LangiumDocument } from "langium";
import { expandToString as s } from "langium/generate";
import { clearDocuments, parseHelper } from "langium/test";
import { createUvlparserServices } from "../../src/language/uvlparser-module.js";
import { FeatureModel, isFeatureModel } from "../../src/language/generated/ast.js";

let services: ReturnType<typeof createUvlparserServices>;
let parse:    ReturnType<typeof parseHelper<FeatureModel>>;
let document: LangiumDocument<FeatureModel> | undefined;

beforeAll(async () => {
    services = createUvlparserServices(EmptyFileSystem);
    parse = parseHelper<FeatureModel>(services.Uvlparser);
});

afterEach(async () => {
    document && clearDocuments(services.shared, [ document ]);
});

describe('Linking tests', () => {

    test('linking of feature model', async () => {
        document = await parse(`
            namespace MyNamespace;

            include MyLanguage;

            features MyFeature {
                String myFeature;
                cardinality [1..*] {
                    or myFeature;
                }
            }

            constraints [
                myFeature == 'example';
            ]
        `);

        expect(
            checkDocumentValid(document)).toBe(s`
            MyFeature
        `);
    });
});

function checkDocumentValid(document: LangiumDocument): string | undefined {
    return document.parseResult.parserErrors.length && s`
        Parser errors:
          ${document.parseResult.parserErrors.map(e => e.message).join('\n  ')}
    `
        || document.parseResult.value === undefined && `ParseResult is 'undefined'.`
        || !isFeatureModel(document.parseResult.value) && `Root AST object is a ${document.parseResult.value.$type}, expected a 'FeatureModel'.`
        || undefined;
}
