import type { ValidationAcceptor, ValidationChecks } from 'langium';
import type { UvlparserAstType, FeatureModel, Feature, Attribute, ValueAttribute, } from './generated/ast.js';
import type { UvlparserServices } from './uvlparser-module.js';

/**
 * Register custom validation checks.
 */
export function registerValidationChecks(services: UvlparserServices) {
    const registry = services.validation.ValidationRegistry;
    const validator = services.validation.UvlparserValidator;
    const checks: ValidationChecks<UvlparserAstType> = {
        FeatureModel: validator.checkFeatureModelValidity,
    };
    registry.register(checks, validator);
}

/**
 * Implementation of custom validations.
 */
export class UvlparserValidator {

    checkFeatureModelValidity(featureModel: FeatureModel, accept: ValidationAcceptor): void {
        this.checkForFeatureAndAttributeDuplication(featureModel, accept);
    };

    checkForFeatureAndAttributeDuplication(featureModel: FeatureModel, accept: ValidationAcceptor): void {
        const seenIds = new Set<string>();

        const traverseFeature = (feature: Feature): void => {
            if (feature.reference?.id) {
                const id = feature.reference.id.toString();

                if (seenIds.has(id)) {
                    accept('error', `Duplicated feature ID: '${id}'`, {
                        node: feature,
                        property: 'reference'
                    });
                } else {
                    seenIds.add(id);
                }
            }

            const seenAttributeKeys = new Set<string>();
            feature.attributes?.forEach((attribute) => {
                attribute.attribute.forEach(el => {
                if (this.isValueAttribute(el)) {
                    const key = el.id?.id.toString();
                    if (key) {
                        if (seenAttributeKeys.has(key)) {
                            accept('error', `Duplicated attribute key: '${key}'`, {
                                node: el,
                            });
                        } else {
                            seenAttributeKeys.add(key);
                        }
                    }
                }})
            });

            feature.group?.forEach((group) => {
                group.feature?.forEach(traverseFeature);
            });
        };

        featureModel.features?.features.forEach(traverseFeature);
    }

    isValueAttribute(attribute: Attribute): attribute is ValueAttribute {
        return 'id' in attribute && (attribute as ValueAttribute).id !== undefined;
    }
    
}
