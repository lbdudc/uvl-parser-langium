import { beforeAll, describe, expect, test } from "vitest";
import { EmptyFileSystem, type LangiumDocument } from "langium";
import { expandToString as s } from "langium/generate";
import { parseHelper } from "langium/test";
import { createUvlparserServices } from "../../src/language/uvlparser-module.js";
import { FeatureModel, isFeatureModel } from "../../src/language/generated/ast.js";

let services: ReturnType<typeof createUvlparserServices>;
let parse:    ReturnType<typeof parseHelper<FeatureModel>>;
let document: LangiumDocument<FeatureModel> | undefined;

beforeAll(async () => {
    services = createUvlparserServices(EmptyFileSystem);
    parse = parseHelper<FeatureModel>(services.Uvlparser);

    // activate the following if your linking test requires elements from a built-in library, for example
    // await services.shared.workspace.WorkspaceManager.initializeWorkspace([]);
});

describe('Parsing tests', () => {

    test('parse simple model', async () => {
        document = await parse(`
            person Langium
            Hello Langium!
        `);

        // check for absensce of parser errors the classic way:
        //  deacivated, find a much more human readable way below!
        // expect(document.parseResult.parserErrors).toHaveLength(0);

        expect(
            // here we use a (tagged) template expression to create a human readable representation
            //  of the AST part we are interested in and that is to be compared to our expectation;
            // prior to the tagged template expression we check for validity of the parsed document object
            //  by means of the reusable function 'checkDocumentValid()' to sort out (critical) typos first;
            checkDocumentValid(document)).toBe(s`
            Persons:
              Langium
            Greetings to:
              Langium
        `);
    });
});

function checkDocumentValid(document: LangiumDocument): string | undefined {
    return document.parseResult.parserErrors.length && s`
        Parser errors:
          ${document.parseResult.parserErrors.map(e => e.message).join('\n  ')}
    `
        || document.parseResult.value === undefined && `ParseResult is 'undefined'.`
        || !isFeatureModel(document.parseResult.value) && `Root AST object is a ${document.parseResult.value.$type}, expected a '${FeatureModel}'.`
        || undefined;
}
