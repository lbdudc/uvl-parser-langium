import type { ValidationAcceptor, ValidationChecks } from 'langium';
import type { UvlparserAstType, FeatureModel, Feature } from './generated/ast.js';
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
        this.checkForFeatureDuplication(featureModel, accept);
    };

    checkForFeatureDuplication(featureModel: FeatureModel, accept: ValidationAcceptor): void {
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

            feature.group?.forEach((group) => {
                group.feature?.forEach(traverseFeature);
            });
        };

        featureModel.features?.features.forEach(traverseFeature);
    }
}
